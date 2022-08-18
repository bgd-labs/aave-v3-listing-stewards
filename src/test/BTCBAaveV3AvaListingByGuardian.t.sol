// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaBTCBListingSteward} from '../contracts/btc.b/AaveV3AvaBTCBListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract BTCBAaveV3AvaListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x4365F8e70CF38C6cA67DE41448508F2da8825500;

    address public constant BTCB = 0x152b9d0FdC40C096757F570A51E494bd4b943E50;

    address public constant BTCB_WHALE =
        0x209a0399A2905900C0d1a9a382fe23e37024dC84;

    address public constant DAIe = 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70;

    address public constant DAI_WHALE =
        0xED2a7edd7413021d440b09D654f3b87712abAB66;

    address public constant RATE_STRATEGY =
        0x5124Efd106b75F6c6876D1c84482D995b8eaD05a;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("avalanche"), 18805477);
    }

    function testListingBTCB() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaBTCBListingSteward listingSteward = new AaveV3AvaBTCBListingSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'BTC.b',
            underlying: BTCB,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 8,
            ltv: 7000,
            liquidationThreshold: 7500,
            liquidationBonus: 10650,
            liquidationProtocolFee: 1000,
            reserveFactor: 1000,
            usageAsCollateralEnabled: true,
            borrowingEnabled: true,
            interestRateStrategy: AaveV3Helpers
                ._findReserveConfig(allConfigsAfter, 'WBTC.e', false)
                .interestRateStrategy,
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            isSiloed: false,
            isBorrowableInIsolation: false,
            supplyCap: 1_000,
            borrowCap: 0,
            debtCeiling: 0,
            eModeCategory: 0
        });

        AaveV3Helpers._validateReserveConfig(
            expectedAssetConfig,
            allConfigsAfter
        );

        AaveV3Helpers._noReservesConfigsChangesApartNewListings(
            allConfigsBefore,
            allConfigsAfter
        );

        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'BTC.b', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(
            BTCB,
            listingSteward.PRICE_FEED_BTCB()
        );

        // impl should be same as e.g. USDC
        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'USDC', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        _validatePoolActionsPostListing(allConfigsAfter);

        require(
            listingSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        address aBTCB = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'BTC.b', false)
            .aToken;
        address vBTCB = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'BTC.b', false)
            .variableDebtToken;
        address sBTCB = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'BTC.b', false)
            .stableDebtToken;
        address vDAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'DAI.e', false)
            .variableDebtToken;

        AaveV3Helpers._deposit(
            vm,
            BTCB_WHALE,
            BTCB_WHALE,
            BTCB,
            1e8,
            true,
            aBTCB
        );

        AaveV3Helpers._borrow(
            vm,
            BTCB_WHALE,
            BTCB_WHALE,
            DAIe,
            10000 ether,
            2,
            vDAI
        );

        AaveV3Helpers._borrow(
            vm,
            BTCB_WHALE,
            BTCB_WHALE,
            BTCB,
            1e7,
            2,
            vBTCB
        );

        // We check proper revert when going over liquidation threshold
        try
            AaveV3Helpers._borrow(
                vm,
                BTCB_WHALE,
                BTCB_WHALE,
                DAIe,
                10000 ether,
                2,
                vDAI
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('36')),
                '_testProposal() : INVALID_VARIABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }

        // We check revert when trying to borrow BTCB with isolated collateral active (BTCB too)
        try
            AaveV3Helpers._borrow(
                vm,
                BTCB_WHALE,
                BTCB_WHALE,
                BTCB,
                1 wei,
                1,
                sBTCB
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('31')),
                '_testProposal() : INVALID_STABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }
    }
}

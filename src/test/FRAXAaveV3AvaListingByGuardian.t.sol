// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaFRAXListingSteward} from '../contracts/frax/AaveV3AvaFRAXListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract FRAXAaveV3AvaListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x4365F8e70CF38C6cA67DE41448508F2da8825500;

    address public constant FRAX = 0xD24C2Ad096400B6FBcd2ad8B24E7acBc21A1da64;

    address public constant FRAX_WHALE =
        0x6FD4b4c38ED80727EcD0d58505565F9e422c965f;

    address public constant DAIe = 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70;

    address public constant DAI_WHALE =
        0xED2a7edd7413021d440b09D654f3b87712abAB66;

    address public constant RATE_STRATEGY =
        0x5124Efd106b75F6c6876D1c84482D995b8eaD05a;

    function setUp() public {}

    function testListingFRAX() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaFRAXListingSteward listingSteward = new AaveV3AvaFRAXListingSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'FRAX',
            underlying: FRAX,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 7500,
            liquidationThreshold: 8000,
            liquidationBonus: 10500,
            liquidationProtocolFee: 1000,
            reserveFactor: 1000,
            usageAsCollateralEnabled: true,
            borrowingEnabled: true,
            interestRateStrategy: AaveV3Helpers
                ._findReserveConfig(allConfigsAfter, 'USDt', false)
                .interestRateStrategy,
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            isSiloed: false,
            supplyCap: 50_000_000,
            borrowCap: 0,
            debtCeiling: 2_000_000_00,
            eModeCategory: 1
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
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'FRAX', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(
            FRAX,
            listingSteward.PRICE_FEED_FRAX()
        );

        // impl should be same as USDC
        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'USDC', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );
        // strategy should be same as USDC
        assertEq(
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'USDC', false).interestRateStrategy,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'FRAX', false).interestRateStrategy
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
        address aFRAX = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'FRAX', false)
            .aToken;
        address vFRAX = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'FRAX', false)
            .variableDebtToken;
        address sFRAX = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'FRAX', false)
            .stableDebtToken;
        address vDAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'DAI.e', false)
            .variableDebtToken;

        AaveV3Helpers._deposit(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            666 ether,
            true,
            aFRAX
        );

        AaveV3Helpers._borrow(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            DAIe,
            222 ether,
            2,
            vDAI
        );

        AaveV3Helpers._borrow(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            200 ether,
            2,
            vFRAX
        );

        // We check proper revert when going over liquidation threshold
        try
            AaveV3Helpers._borrow(
                vm,
                FRAX_WHALE,
                FRAX_WHALE,
                FRAX,
                200 ether,
                2,
                vFRAX
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

        // We check revert when trying to borrow at stable
        try
            AaveV3Helpers._borrow(
                vm,
                FRAX_WHALE,
                FRAX_WHALE,
                FRAX,
                10 ether,
                1,
                sFRAX
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('31')),
                '_testProposal() : INVALID_VARIABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }

        vm.startPrank(DAI_WHALE);
        IERC20(DAIe).transfer(FRAX_WHALE, 300 ether);
        vm.stopPrank();

        // Not possible to borrow and repay when vdebt index doesn't changing, so moving 1s
        skip(1);

        AaveV3Helpers._repay(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            DAIe,
            IERC20(DAIe).balanceOf(FRAX_WHALE),
            2,
            vDAI,
            true
        );

        AaveV3Helpers._repay(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            IERC20(FRAX).balanceOf(FRAX_WHALE),
            2,
            vFRAX,
            true
        );

        AaveV3Helpers._withdraw(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            type(uint256).max,
            aFRAX
        );
    }
}

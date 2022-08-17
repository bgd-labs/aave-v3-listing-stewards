// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3SAVAXListingSteward} from '../contracts/savax/AaveV3SAVAXListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract sAVAXAaveV3AvaListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x4365F8e70CF38C6cA67DE41448508F2da8825500;

    address public constant SAVAX = 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE;

    address public constant SAVAX_WHALE =
        0x8B3D19047c35AF317A4393483a356762bEeC69A5;

    address public constant DAIe = 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70;

    address public constant DAI_WHALE =
        0xED2a7edd7413021d440b09D654f3b87712abAB66;

    address public constant SAVAX_PRICE_FEED =
        0xc9245871D69BF4c36c6F2D15E0D68Ffa883FE1A7;

    address public constant RATE_STRATEGY =
        0x79a906e8c998d2fb5C5D66d23c4c5416Fe0168D6;

    function setUp() public {}

    function testListingSAVAX() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3SAVAXListingSteward listingSteward = new AaveV3SAVAXListingSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'sAVAX',
            underlying: SAVAX,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 2000,
            liquidationThreshold: 3000,
            liquidationBonus: 11000,
            liquidationProtocolFee: 1000,
            reserveFactor: 1000,
            usageAsCollateralEnabled: true,
            borrowingEnabled: false,
            interestRateStrategy: RATE_STRATEGY,
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            isSiloed: false,
            isBorrowableInIsolation: false,
            supplyCap: 500_000,
            borrowCap: 0,
            debtCeiling: 0,
            eModeCategory: 2
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
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'sAVAX', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(SAVAX, SAVAX_PRICE_FEED);

        _validatePoolActionsPostListing(allConfigsAfter);

        require(
            listingSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );

        string[] memory expectedAssetsEmode = new string[](2);
        expectedAssetsEmode[0] = 'WAVAX';
        expectedAssetsEmode[1] = 'sAVAX';

        AaveV3Helpers._validateAssetsOnEmodeCategory(
            2,
            allConfigsAfter,
            expectedAssetsEmode
        );
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        AaveV3Helpers._deposit(
            vm,
            SAVAX_WHALE,
            SAVAX_WHALE,
            SAVAX,
            666 ether,
            true,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'sAVAX', false)
                .aToken
        );

        AaveV3Helpers._borrow(
            vm,
            SAVAX_WHALE,
            SAVAX_WHALE,
            DAIe,
            222 ether,
            2,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'DAI.e', false)
                .variableDebtToken
        );

        // Only checking with 1 borrowing type, because we can understand that borrowing is disabled
        // with the revert reason (BORROWING_NOT_ENABLED = 30)
        try
            AaveV3Helpers._borrow(
                vm,
                SAVAX_WHALE,
                SAVAX_WHALE,
                SAVAX,
                5 ether,
                2,
                AaveV3Helpers
                    ._findReserveConfig(allReservesConfigs, 'sAVAX', false)
                    .stableDebtToken
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('30')),
                '_testProposal() : INVALID_VARIABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }

        vm.startPrank(DAI_WHALE);
        IERC20(DAIe).transfer(SAVAX_WHALE, 300 ether);
        vm.stopPrank();

        // Not possible to borrow and repay when vdebt index doesn't changing, so moving 1s
        skip(1);

        AaveV3Helpers._repay(
            vm,
            SAVAX_WHALE,
            SAVAX_WHALE,
            DAIe,
            IERC20(DAIe).balanceOf(SAVAX_WHALE),
            2,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'DAI.e', false)
                .variableDebtToken,
            true
        );

        AaveV3Helpers._withdraw(
            vm,
            SAVAX_WHALE,
            SAVAX_WHALE,
            SAVAX,
            type(uint256).max,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'sAVAX', false)
                .aToken
        );
    }
}

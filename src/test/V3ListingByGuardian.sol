// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes} from '../contracts/interfaces/IPoolConfigurator.sol';
import {IACLManager} from '../contracts/interfaces/IACLManager.sol';
import {AaveV3FRAXListingSteward} from '../contracts/AaveV3SFRAXListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract V3ListingByGuardian is Test {
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

    function setUp() public {}

    function testAddSingleDistribution() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3FRAXListingSteward listingSteward = new AaveV3FRAXListingSteward();

        IACLManager aclManager = listingSteward.ACL_MANAGER();

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'FRAX',
            underlying: 0xD24C2Ad096400B6FBcd2ad8B24E7acBc21A1da64,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 6,
            ltv: 7500,
            liquidationThreshold: 8000,
            liquidationBonus: 11000,
            reserveFactor: 500,
            usageAsCollateralEnabled: true,
            borrowingEnabled: false,
            interestRateStrategy: address(0),
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            supplyCap: 500_000,
            borrowCap: 0,
            debtCeiling: 0
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

        console.log(
            AaveV3Helpers
                ._findReserveConfig(allConfigsAfter, 'FRAX', false)
                .aToken
        );
        _validatePoolActionsPostListing(allConfigsAfter);
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        
        AaveV3Helpers._deposit(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            666,
            true,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'FRAX', false)
                .aToken
        );



        AaveV3Helpers._borrow(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            DAIe,
            222,
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
                FRAX_WHALE,
                FRAX_WHALE,
                FRAX,
                5 ether,
                2,
                AaveV3Helpers
                    ._findReserveConfig(allReservesConfigs, 'FRAX', false)
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
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'DAI.e', false)
                .variableDebtToken,
            true
        );

        AaveV3Helpers._withdraw(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            type(uint256).max,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'FRAX', false)
                .aToken
        );
    }
}

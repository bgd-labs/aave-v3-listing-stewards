// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes} from '../contracts/interfaces/IPoolConfigurator.sol';
import {IACLManager} from '../contracts/interfaces/IACLManager.sol';
import {AaveV3SAVAXListingSteward} from '../contracts/savax/AaveV3SAVAXListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';
import {sAVAXOracleAdapter} from '../contracts/savax/sAVAXOracleAdapter.sol';

contract sAVAXAaveV3AvaListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x4365F8e70CF38C6cA67DE41448508F2da8825500;

    address public constant SAVAX = 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE;

    address public constant SAVAX_WHALE =
        0xf973C06c8964C1650e210c940db65Acbf7F2a48D;

    address public constant DAIe = 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70;

    address public constant DAI_WHALE =
        0xED2a7edd7413021d440b09D654f3b87712abAB66;

    function setUp() public {}

    function testListing() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        sAVAXOracleAdapter oracleAdapter = new sAVAXOracleAdapter();

        AaveV3SAVAXListingSteward listingSteward = new AaveV3SAVAXListingSteward(
                address(oracleAdapter)
            );

        IACLManager aclManager = listingSteward.ACL_MANAGER();

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'sAVAX',
            underlying: 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 5000,
            liquidationThreshold: 6500,
            liquidationBonus: 11000,
            reserveFactor: 1000,
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
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'sAVAX', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(
            SAVAX,
            listingSteward.SAVAX_PRICE_FEED()
        );

        _validatePoolActionsPostListing(allConfigsAfter);
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

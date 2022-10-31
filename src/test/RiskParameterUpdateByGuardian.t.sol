// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaRiskParameterUpdate} from '../contracts/gauntlet/AaveV3AvaRiskParameterUpdate.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract RiskParameterUpdateByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x4365F8e70CF38C6cA67DE41448508F2da8825500;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("avalanche"), 18805477);
    }

    function testRiskParameterUpdate() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaRiskParameterUpdate updateSteward = new AaveV3AvaRiskParameterUpdate();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(updateSteward));
        aclManager.addRiskAdmin(address(updateSteward));

        updateSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        // ReserveConfig memory expectedAssetConfig = ReserveConfig({
        //     symbol: 'BTC.b',
        //     underlying: BTCB,
        //     aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
        //     variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
        //     stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
        //     decimals: 8,
        //     ltv: 7000,
        //     liquidationThreshold: 7500,
        //     liquidationBonus: 10650,
        //     liquidationProtocolFee: 1000,
        //     reserveFactor: 2000,
        //     usageAsCollateralEnabled: true,
        //     borrowingEnabled: true,
        //     interestRateStrategy: AaveV3Helpers
        //         ._findReserveConfig(allConfigsAfter, 'WBTC.e', false)
        //         .interestRateStrategy,
        //     stableBorrowRateEnabled: false,
        //     isActive: true,
        //     isFrozen: false,
        //     isSiloed: false,
        //     isBorrowableInIsolation: false,
        //     supplyCap: 2_900,
        //     borrowCap: 1_450,
        //     debtCeiling: 0,
        //     eModeCategory: 0
        // });

        // AaveV3Helpers._validateReserveConfig(
        //     expectedAssetConfig,
        //     allConfigsAfter
        // );

        // AaveV3Helpers._noReservesConfigsChangesApartFrom(
        //     allConfigsBefore,
        //     allConfigsAfter,
        //     'BTC.b'
        // );

        require(
            updateSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );
    }
}

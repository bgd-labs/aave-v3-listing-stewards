// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaRiskParameterUpdate, Updates} from '../contracts/gauntlet/AaveV3AvaRiskParameterUpdate.sol';
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

        Updates memory updates = updateSteward._getUpdates();
        string[] memory symbols = new string[](updates.parameters.length);

        for (uint256 i = 0; i < updates.parameters.length; i++) {
            symbols[i] = updates.parameters[i].symbol;

            ReserveConfig memory expectedConfig = AaveV3Helpers._findReserveConfig(allConfigsBefore, symbols[i], false);
            expectedConfig.ltv = updates.parameters[i].ltv;
            expectedConfig.liquidationThreshold = updates.parameters[i].liquidationThreshold;
            expectedConfig.liquidationBonus = updates.parameters[i].liquidationBonus;

            AaveV3Helpers._validateReserveConfig(
                expectedConfig,
                allConfigsAfter
            );
        }

        AaveV3Helpers._noReservesConfigsChangesApartFromMany(
            allConfigsBefore,
            allConfigsAfter,
            symbols
        );

        require(
            updateSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );
    }
}

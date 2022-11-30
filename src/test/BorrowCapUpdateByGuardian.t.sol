// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaBorrowCapsUpdate, ParameterSet, NUM_UPDATES} from '../contracts/gauntlet/AaveV3AvaBorrowCapsUpdate.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract BorrowCapUpdateByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("avalanche"), 22760128);
    }

    function testBorrowCapsUpdate() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaBorrowCapsUpdate updateSteward = new AaveV3AvaBorrowCapsUpdate();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addRiskAdmin(address(updateSteward));

        updateSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ParameterSet[NUM_UPDATES] memory parameters = updateSteward._getUpdates();
        string[] memory symbols = new string[](parameters.length);

        for (uint256 i = 0; i < parameters.length; i++) {
            symbols[i] = parameters[i].symbol;

            ReserveConfig memory expectedConfig = AaveV3Helpers._findReserveConfig(allConfigsBefore, symbols[i], false);
            expectedConfig.borrowCap = parameters[i].borrowCap;

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

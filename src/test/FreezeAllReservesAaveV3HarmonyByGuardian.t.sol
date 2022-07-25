// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import 'forge-std/Test.sol';

import {AaveV3Harmony} from 'aave-address-book/AaveAddressBook.sol';
import {FreezeHarmonyPoolReservesSteward} from '../contracts/harmony-protection/FreezeHarmonyPoolReservesSteward.sol';
import {AaveV3Helpers, ReserveConfig} from './helpers/AaveV3Helpers.sol';

contract FreezeAllReservesAaveV3HarmonyByGuardian is Test {
    address public constant GUARDIAN =
        0xb2f0C5f37f4beD2cB51C44653cD5D84866BDcd2D;

    function setUp() public {}

    function testFreezingAllReserves() public {
        vm.startPrank(GUARDIAN);

        FreezeHarmonyPoolReservesSteward freezeSteward = new FreezeHarmonyPoolReservesSteward();

        AaveV3Harmony.ACL_MANAGER.addRiskAdmin(address(freezeSteward));

        freezeSteward.freezeAllReserves();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        for (uint256 i = 0; i < allConfigsAfter.length; i++) {
            assertTrue(allConfigsAfter[i].isFrozen, 'RESERVE_NOT_FROZEN');
        }
    }
}

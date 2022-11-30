// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaBorrowCapsUpdate} from '../src/contracts/gauntlet/AaveV3AvaBorrowCapsUpdate.sol';

address constant BORROW_CAPS_STEWARD = 0x4393277B02ef3cA293990A772B7160a8c76F2443;

contract ExecuteAaveV3AvaBorrowCapsSteward is Script {
    function run() external {
        AaveV3AvaBorrowCapsUpdate steward = AaveV3AvaBorrowCapsUpdate(BORROW_CAPS_STEWARD);
        vm.startBroadcast();
        steward.execute();
        vm.stopBroadcast();
    }
}

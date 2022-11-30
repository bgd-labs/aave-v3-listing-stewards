// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaBorrowCapsUpdate} from '../src/contracts/gauntlet/AaveV3AvaBorrowCapsUpdate.sol';

contract DeployAaveV3AvaBorrowCapsSteward is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3AvaBorrowCapsUpdate();
        vm.stopBroadcast();
    }
}

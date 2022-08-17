// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaMAIListingSteward} from '../src/contracts/mimatic/AaveV3AvaMAIListingSteward.sol';

contract DeployAvaMAISteward is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3AvaMAIListingSteward();
        vm.stopBroadcast();
    }
}

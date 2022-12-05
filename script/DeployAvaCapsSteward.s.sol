// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaCapsSteward} from '../src/contracts/v3-ava-supply-caps-30-11-2022/AaveV3AvaCapsSteward.sol';

contract DeployAvaCapsSteward is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3AvaCapsSteward();
        vm.stopBroadcast();
    }
}

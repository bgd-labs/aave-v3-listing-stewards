// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {FreezeFantomPoolReservesSteward} from '../src/contracts/fantom-freeze/FreezeFantomPoolReservesSteward.sol';

contract DeployFantomFreezeSteward is Script {
    function run() external {
        vm.startBroadcast();
        new FreezeFantomPoolReservesSteward();
        vm.stopBroadcast();
    }
}

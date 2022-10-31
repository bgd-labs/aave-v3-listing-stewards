// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaRiskParameterUpdate} from '../src/contracts/gauntlet/AaveV3AvaRiskParameterUpdate.sol';

contract DeployAaveV3AvaRiskParameterSteward is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3AvaRiskParameterUpdate();
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaRiskParamsSteward} from '../src/contracts/v3-ava-risk-params-20-02-2023/AaveV3AvaRiskParamsSteward.sol';

contract DeployAvaRiskParamsSteward is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3AvaRiskParamsSteward();
        vm.stopBroadcast();
    }
}

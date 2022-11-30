// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaRiskParameterUpdate} from '../src/contracts/gauntlet/AaveV3AvaRiskParameterUpdate.sol';

address constant RISK_STEWARD = 0x4c68fDA91bfb4683eAB90017d9B76a99F2d77Eed;

contract ExecuteAaveV3AvaRiskParameterSteward is Script {
    function run() external {
        AaveV3AvaRiskParameterUpdate steward = AaveV3AvaRiskParameterUpdate(RISK_STEWARD);
        vm.startBroadcast();
        steward.execute();
        vm.stopBroadcast();
    }
}

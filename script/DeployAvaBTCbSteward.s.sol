// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {AaveV3AvaBTCBListingSteward} from '../src/contracts/btc.b/AaveV3AvaBTCBListingSteward.sol';

contract DeployAvaBTCbSteward is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3AvaBTCBListingSteward();
        vm.stopBroadcast();
    }
}

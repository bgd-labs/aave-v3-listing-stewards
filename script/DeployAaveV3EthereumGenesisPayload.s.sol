// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {AaveV3EthereumGenesisPayload} from '../src/contracts/v3-ethereum/AaveV3EthereumGenesisPayload.sol';
import {IGenericV3ListingEngine} from '../src/contracts/common/IGenericV3ListingEngine.sol';

contract DeployAaveV3EthereumGenesisPayload is Script {
    function run() external {
        vm.startBroadcast();
        new AaveV3EthereumGenesisPayload(IGenericV3ListingEngine(address(0))); // TODO add a correct listing engine
        vm.stopBroadcast();
    }
}

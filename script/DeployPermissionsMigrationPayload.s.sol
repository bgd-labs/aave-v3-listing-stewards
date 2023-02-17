// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {PermissionsMigrationPayload} from '../src/contracts/misc-guardian/PermissionsMigrationPayload.sol';
import {CollectorPermissionsMigrationPayload} from '../src/contracts/misc-guardian/CollectorPermissionsMigrationPayload.sol';

library OptimismPayloadLib {
  function _deploy() internal returns (PermissionsMigrationPayload) {
    return
      new PermissionsMigrationPayload(
        AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
        AaveV3Optimism.WETH_GATEWAY,
        AaveV3Optimism.EMISSION_MANAGER,
        AaveV3Optimism.POOL_ADDRESSES_PROVIDER_REGISTRY,
        AaveV3Optimism.ACL_MANAGER,
        AaveV3Optimism.POOL_ADDRESSES_PROVIDER
      );
  }

  function _deployPayloadCollector() internal returns (CollectorPermissionsMigrationPayload) {
    return
      new CollectorPermissionsMigrationPayload(
        AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
        AaveV3Optimism.COLLECTOR,
        AaveV3Optimism.COLLECTOR_CONTROLLER,
        AaveV3Optimism.SWAP_COLLATERAL_ADAPTER,
        AaveV3Optimism.REPAY_WITH_COLLATERAL_ADAPTER
      );
  }
}

library ArbitrumPayloadLib {
  function _deploy() internal returns (PermissionsMigrationPayload) {
    return
      new PermissionsMigrationPayload(
        AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
        AaveV3Arbitrum.WETH_GATEWAY,
        AaveV3Arbitrum.EMISSION_MANAGER,
        AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER_REGISTRY,
        AaveV3Arbitrum.ACL_MANAGER,
        AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER
      );
  }

  function _deployPayloadCollector() internal returns (CollectorPermissionsMigrationPayload) {
    return
      new CollectorPermissionsMigrationPayload(
        AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
        AaveV3Arbitrum.COLLECTOR,
        AaveV3Arbitrum.COLLECTOR_CONTROLLER,
        AaveV3Arbitrum.SWAP_COLLATERAL_ADAPTER,
        AaveV3Arbitrum.REPAY_WITH_COLLATERAL_ADAPTER
      );
  }
}

contract DeployOptimismPayload is Script {
  function run() external {
    vm.startBroadcast();
    OptimismPayloadLib._deploy();
    vm.stopBroadcast();
  }
}

contract DeployArbitrumPayload is Script {
  function run() external {
    vm.startBroadcast();
    ArbitrumPayloadLib._deploy();
    vm.stopBroadcast();
  }
}

contract DeployCollectorOptimismPayload is Script {
  function run() external {
    vm.startBroadcast();
    OptimismPayloadLib._deployPayloadCollector();
    vm.stopBroadcast();
  }
}

contract DeployCollectorArbitrumPayload is Script {
  function run() external {
    vm.startBroadcast();
    ArbitrumPayloadLib._deployPayloadCollector();
    vm.stopBroadcast();
  }
}

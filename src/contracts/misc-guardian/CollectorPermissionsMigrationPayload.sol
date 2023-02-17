// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICollector} from 'aave-address-book/AaveV3.sol';
import {IOwnable} from '../interfaces/IOwnable.sol';

interface ITransparentProxy {
  function changeAdmin(address newAdmin) external;
}

/**
 * @dev One-time-use helper contract to be used by Aave Guardians (Gnosis Safe generally) to do migration
 *  of permissions to the cross-chain governance system, in this case, of Collector-related contracts.
 *  - Different to the Steward patterns, this payload is designed to be executed via DELEGATECALL on the Gnosis Safe
 *  - The payload doesn't affect anyhow the storage of the address "running it".
 *  - This migration has been done ad-hoc, taking into account how permissions are in the networks target: Optimism
 *    and Arbitrum.
 */
contract CollectorPermissionsMigrationPayload {
  ITransparentProxy public immutable COLLECTOR;
  IOwnable public immutable CONTROLLER_OF_COLLECTOR;
  address public immutable BRIDGE_EXECUTOR;
  IOwnable public immutable COLLATERAL_SWAP_ADAPTER;
  IOwnable public immutable REPAY_WITH_COLLATERAL_ADAPTER;

  constructor(
    address bridgeExecutor,
    address collector,
    ICollector controllerOfCollector,
    address collateralSwapAdapter,
    address repayWithCollateralAdapter
  ) {
    COLLECTOR = ITransparentProxy(collector);
    CONTROLLER_OF_COLLECTOR = IOwnable(address(controllerOfCollector));
    BRIDGE_EXECUTOR = bridgeExecutor;
    COLLATERAL_SWAP_ADAPTER = IOwnable(collateralSwapAdapter);
    REPAY_WITH_COLLATERAL_ADAPTER = IOwnable(repayWithCollateralAdapter);
  }

  function execute() external {
    CONTROLLER_OF_COLLECTOR.transferOwnership(BRIDGE_EXECUTOR);
    COLLECTOR.changeAdmin(BRIDGE_EXECUTOR);
    COLLATERAL_SWAP_ADAPTER.transferOwnership(BRIDGE_EXECUTOR);
    REPAY_WITH_COLLATERAL_ADAPTER.transferOwnership(BRIDGE_EXECUTOR);
  }
}

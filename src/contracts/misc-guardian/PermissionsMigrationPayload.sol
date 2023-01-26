// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {IACLManager, IPoolAddressesProvider} from 'aave-address-book/AaveV3.sol';
import {IOwnable} from '../interfaces/IOwnable.sol';

/**
 * @dev One-time-use helper contract to be used by Aave Guardians (Gnosis Safe generally) to do migration
 *  of permissions to the cross-chain governance system.
 *  - Different to the Steward patterns, this payload is designed to be executed via DELEGATECALL on the Gnosis Safe
 *  - The payload doesn't affect anyhow the storage of the address "running it".
 *  - This migration has been done ad-hoc, taking into account how permissions are in the networks target: Optimism
 *    and Arbitrum.
 */
contract PermissionsMigrationPayload {
  address public immutable BRIDGE_EXECUTOR;
  IOwnable public immutable WRAPPED_TOKEN_GATEWAY;
  IOwnable public immutable EMISSION_MANAGER;
  IOwnable public immutable POOL_ADDRESSES_PROVIDER_REGISTRY;
  IACLManager public immutable ACL_MANAGER;
  IPoolAddressesProvider public immutable POOL_ADDRESSES_PROVIDER;

  constructor(
    address bridgeExecutor,
    address wrappedTokenGateway,
    address emissionManager,
    address addressesProviderRegistry,
    IACLManager aclManager,
    IPoolAddressesProvider poolAddressesProvider
  ) {
    BRIDGE_EXECUTOR = bridgeExecutor;
    WRAPPED_TOKEN_GATEWAY = IOwnable(wrappedTokenGateway);
    EMISSION_MANAGER = IOwnable(emissionManager);
    POOL_ADDRESSES_PROVIDER_REGISTRY = IOwnable(addressesProviderRegistry);
    ACL_MANAGER = aclManager;
    POOL_ADDRESSES_PROVIDER = poolAddressesProvider;
  }

  function execute() external {
    WRAPPED_TOKEN_GATEWAY.transferOwnership(BRIDGE_EXECUTOR);
    EMISSION_MANAGER.transferOwnership(BRIDGE_EXECUTOR);
    POOL_ADDRESSES_PROVIDER_REGISTRY.transferOwnership(BRIDGE_EXECUTOR);

    ACL_MANAGER.renounceRole(ACL_MANAGER.POOL_ADMIN_ROLE(), address(this));
    POOL_ADDRESSES_PROVIDER.setACLAdmin(BRIDGE_EXECUTOR);
    IOwnable(address(POOL_ADDRESSES_PROVIDER)).transferOwnership(BRIDGE_EXECUTOR);
    ACL_MANAGER.grantRole(ACL_MANAGER.DEFAULT_ADMIN_ROLE(), BRIDGE_EXECUTOR);
    ACL_MANAGER.revokeRole(ACL_MANAGER.DEFAULT_ADMIN_ROLE(), address(this));
  }
}

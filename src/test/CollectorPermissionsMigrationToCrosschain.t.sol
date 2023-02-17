// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {TestWithExecutor} from 'aave-helpers/GovHelpers.sol';
import {ProxyHelpers} from 'aave-helpers/ProxyHelpers.sol';
import {IOwnable} from '../contracts/interfaces/IOwnable.sol';
import {PermissionsData, BaseAavePermissionsHelper} from './helpers/PermissionsHelpers.sol';
import {OptimismPayloadLib, ArbitrumPayloadLib} from '../../script/DeployPermissionsMigrationPayload.s.sol';

contract CollectorPermissionsMigrationToCrosschain is TestWithExecutor, BaseAavePermissionsHelper {
  function testPermissionsMigrationOptimism() public {
    vm.createSelectFork('optimism', 74940500);
    _selectPayloadExecutor(PermissionsData.AAVE_GUARDIAN_OPTIMISM);

    // -------------------------------------------------
    // 1. We generate a permissions report pre-migration
    // -------------------------------------------------

    string memory PATH_REPORT_PRE = './reports/Optimism_permissions-pre-migration.md';

    vm.writeFile(PATH_REPORT_PRE, '');
    _writePermissionsTable(
      PermissionsData.OP_ID,
      PATH_REPORT_PRE,
      PermissionsData._getPermissionsSourcesOp(),
      PermissionsData._pickAddressesKnownAccounts(PermissionsData._getKnownAccountsOp())
    );

    // ---------------------------------------------------------
    // 2. We deploy and execute the payload on the Guardian Safe
    // ---------------------------------------------------------

    _executePayload(address(OptimismPayloadLib._deployPayloadCollector()));

    // --------------------------------------------------
    // 3. We generate a permissions report post-migration
    // --------------------------------------------------

    string memory PATH_REPORT_POST = './reports/Optimism_permissions-post-migration.md';

    vm.writeFile(PATH_REPORT_POST, '');
    _writePermissionsTable(
      PermissionsData.OP_ID,
      PATH_REPORT_POST,
      PermissionsData._getPermissionsSourcesOp(),
      PermissionsData._pickAddressesKnownAccounts(PermissionsData._getKnownAccountsOp())
    );

    // ------------------------
    // 4. We do the validations
    // ------------------------

    assertEq(
      IOwnable(AaveV3Optimism.WETH_GATEWAY).owner(),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Invalid owner of Gateway'
    );
    assertEq(
      IOwnable(AaveV3Optimism.EMISSION_MANAGER).owner(),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Invalid owner of Emission Manager'
    );
    assertEq(
      IOwnable(AaveV3Optimism.POOL_ADDRESSES_PROVIDER_REGISTRY).owner(),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Invalid owner of Addresses Provider Registry'
    );
    assertFalse(
      AaveV3Optimism.ACL_MANAGER.isPoolAdmin(PermissionsData.AAVE_GUARDIAN_OPTIMISM),
      'Guardian should not be POOL_ADMIN'
    );
    assertTrue(
      AaveV3Optimism.ACL_MANAGER.isPoolAdmin(AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR),
      'Bridge Executor should be POOL_ADMIN'
    );
    assertEq(
      AaveV3Optimism.POOL_ADDRESSES_PROVIDER.getACLAdmin(),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Bridge Executor should be ACL Admin on Addresses Provider'
    );
    assertEq(
      IOwnable(address(AaveV3Optimism.POOL_ADDRESSES_PROVIDER)).owner(),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Invalid owner of Addresses Provider'
    );
    assertEq(
      IOwnable(address(AaveV3Optimism.COLLECTOR_CONTROLLER)).owner(),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Invalid owner of Collector of Controller'
    );
    assertEq(
      ProxyHelpers.getInitializableAdminUpgradeabilityProxyAdmin(vm, AaveV3Optimism.COLLECTOR),
      AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      'Invalid proxy admin of Collector'
    );
    assertTrue(
      AaveV3Optimism.ACL_MANAGER.hasRole(
        AaveV3Optimism.ACL_MANAGER.DEFAULT_ADMIN_ROLE(),
        AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR
      )
    );
    assertFalse(
      AaveV3Optimism.ACL_MANAGER.hasRole(
        AaveV3Optimism.ACL_MANAGER.DEFAULT_ADMIN_ROLE(),
        PermissionsData.AAVE_GUARDIAN_OPTIMISM
      )
    );
  }

  function testPermissionsMigrationArbitrum() public {
    vm.createSelectFork('arbitrum', 61747690);
    _selectPayloadExecutor(PermissionsData.AAVE_GUARDIAN_ARBITRUM);

    // -------------------------------------------------
    // 1. We generate a permissions report pre-migration
    // -------------------------------------------------

    string memory PATH_REPORT_PRE = './reports/Arbitrum_permissions-pre-migration.md';

    vm.writeFile(PATH_REPORT_PRE, '');
    _writePermissionsTable(
      PermissionsData.ARB_ID,
      PATH_REPORT_PRE,
      PermissionsData._getPermissionsSourcesArb(),
      PermissionsData._pickAddressesKnownAccounts(PermissionsData._getKnownAccountsArb())
    );

    // ---------------------------------------------------------
    // 2. We deploy and execute the payload on the Guardian Safe
    // ---------------------------------------------------------

    _executePayload(address(ArbitrumPayloadLib._deployPayloadCollector()));

    // --------------------------------------------------
    // 3. We generate a permissions report post-migration
    // --------------------------------------------------

    string memory PATH_REPORT_POST = './reports/Arbitrum_permissions-post-migration.md';

    vm.writeFile(PATH_REPORT_POST, '');
    _writePermissionsTable(
      PermissionsData.ARB_ID,
      PATH_REPORT_POST,
      PermissionsData._getPermissionsSourcesArb(),
      PermissionsData._pickAddressesKnownAccounts(PermissionsData._getKnownAccountsArb())
    );

    // ------------------------
    // 4. We do the validations
    // ------------------------

    assertEq(
      IOwnable(AaveV3Arbitrum.WETH_GATEWAY).owner(),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Invalid owner of Gateway'
    );
    assertEq(
      IOwnable(AaveV3Arbitrum.EMISSION_MANAGER).owner(),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Invalid owner of Emission Manager'
    );
    assertEq(
      IOwnable(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER_REGISTRY).owner(),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Invalid owner of Addresses Provider Registry'
    );
    assertFalse(
      AaveV3Arbitrum.ACL_MANAGER.isPoolAdmin(PermissionsData.AAVE_GUARDIAN_ARBITRUM),
      'Guardian should not be POOL_ADMIN'
    );
    assertTrue(
      AaveV3Arbitrum.ACL_MANAGER.isPoolAdmin(AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR),
      'Bridge Executor should be POOL_ADMIN'
    );
    assertEq(
      AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER.getACLAdmin(),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Bridge Executor should be ACL Admin on Addresses Provider'
    );
    assertEq(
      IOwnable(address(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER)).owner(),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Invalid owner of Addresses Provider'
    );
    assertEq(
      IOwnable(address(AaveV3Arbitrum.COLLECTOR_CONTROLLER)).owner(),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Invalid owner of Collector of Controller'
    );
    assertEq(
      ProxyHelpers.getInitializableAdminUpgradeabilityProxyAdmin(vm, AaveV3Arbitrum.COLLECTOR),
      AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      'Invalid proxy admin of Collector'
    );
    assertTrue(
      AaveV3Arbitrum.ACL_MANAGER.hasRole(
        AaveV3Arbitrum.ACL_MANAGER.DEFAULT_ADMIN_ROLE(),
        AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR
      )
    );
    assertFalse(
      AaveV3Arbitrum.ACL_MANAGER.hasRole(
        AaveV3Arbitrum.ACL_MANAGER.DEFAULT_ADMIN_ROLE(),
        PermissionsData.AAVE_GUARDIAN_ARBITRUM
      )
    );
  }
}

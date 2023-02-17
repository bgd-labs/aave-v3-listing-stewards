// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from 'forge-std/Vm.sol';
import {Test} from 'forge-std/Test.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {IACLManager, IPoolAddressesProvider} from 'aave-address-book/AaveV3.sol';
import {IOwnable} from '../../contracts/interfaces/IOwnable.sol';
import {ProxyHelpers} from 'aave-helpers/ProxyHelpers.sol';

library PermissionsData {
  address internal constant AAVE_GUARDIAN_ARBITRUM = 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb;
  address internal constant AAVE_GUARDIAN_OPTIMISM = 0xE50c8C619d05ff98b22Adf991F17602C774F785c;
  address internal constant DEPLOYER_ACCOUNT_ARBITRUM = 0x4365F8e70CF38C6cA67DE41448508F2da8825500;
  address internal constant DEPLOYER_ACCOUNT_OPTIMISM = 0x4365F8e70CF38C6cA67DE41448508F2da8825500;
  string internal constant ARB_ID = 'Arb';
  string internal constant OP_ID = 'Op';

  struct PermissionHolder {
    address who;
    string name;
  }

  struct AavePermissionsSources {
    address addressesProvider;
    address addressesProviderRegistry;
    address repayCollateralAdapter;
    address swapCollateralAdapter;
    address wrappedTokenGateway;
    address emissionManager;
    address aclManager;
    address collector;
    address controllerOfCollector;
  }

  function _getPermissionsSourcesArb() internal pure returns (AavePermissionsSources memory) {
    return
      AavePermissionsSources({
        addressesProvider: address(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER),
        addressesProviderRegistry: address(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER_REGISTRY),
        repayCollateralAdapter: address(AaveV3Arbitrum.REPAY_WITH_COLLATERAL_ADAPTER),
        swapCollateralAdapter: address(AaveV3Arbitrum.SWAP_COLLATERAL_ADAPTER),
        wrappedTokenGateway: address(AaveV3Arbitrum.WETH_GATEWAY),
        emissionManager: address(AaveV3Arbitrum.EMISSION_MANAGER),
        aclManager: address(AaveV3Arbitrum.ACL_MANAGER),
        collector: AaveV3Arbitrum.COLLECTOR,
        controllerOfCollector: address(AaveV3Arbitrum.COLLECTOR_CONTROLLER)
      });
  }

  function _getPermissionsSourcesOp() internal pure returns (AavePermissionsSources memory) {
    return
      AavePermissionsSources({
        addressesProvider: address(AaveV3Optimism.POOL_ADDRESSES_PROVIDER),
        addressesProviderRegistry: address(AaveV3Optimism.POOL_ADDRESSES_PROVIDER_REGISTRY),
        repayCollateralAdapter: address(AaveV3Optimism.REPAY_WITH_COLLATERAL_ADAPTER),
        swapCollateralAdapter: address(AaveV3Optimism.SWAP_COLLATERAL_ADAPTER),
        wrappedTokenGateway: address(AaveV3Optimism.WETH_GATEWAY),
        emissionManager: address(AaveV3Optimism.EMISSION_MANAGER),
        aclManager: address(AaveV3Optimism.ACL_MANAGER),
        collector: AaveV3Optimism.COLLECTOR,
        controllerOfCollector: address(AaveV3Optimism.COLLECTOR_CONTROLLER)
      });
  }

  function _getKnownAccountsArb() internal pure returns (PermissionHolder[] memory) {
    PermissionHolder[] memory permissionHolders = new PermissionHolder[](3);
    permissionHolders[0] = PermissionHolder({who: AAVE_GUARDIAN_ARBITRUM, name: 'Guardian'});
    permissionHolders[1] = PermissionHolder({
      who: AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR,
      name: 'Bridge Executor'
    });
    permissionHolders[2] = PermissionHolder({
      who: DEPLOYER_ACCOUNT_ARBITRUM,
      name: 'Deployer Account'
    });

    return permissionHolders;
  }

  function _getKnownAccountsOp() internal pure returns (PermissionHolder[] memory) {
    PermissionHolder[] memory permissionHolders = new PermissionHolder[](3);
    permissionHolders[0] = PermissionHolder({who: AAVE_GUARDIAN_OPTIMISM, name: 'Guardian'});
    permissionHolders[1] = PermissionHolder({
      who: AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR,
      name: 'Bridge Executor'
    });
    permissionHolders[2] = PermissionHolder({
      who: DEPLOYER_ACCOUNT_OPTIMISM,
      name: 'Deployer Account'
    });

    return permissionHolders;
  }

  function _pickAddressesKnownAccounts(PermissionHolder[] memory knownAccounts)
    internal
    pure
    returns (address[] memory)
  {
    address[] memory addresses = new address[](knownAccounts.length);
    for (uint256 i = 0; i < addresses.length; i++) {
      addresses[i] = knownAccounts[i].who;
    }

    return addresses;
  }
}

abstract contract BaseAavePermissionsHelper is Test {
  function _chooseIdentifyAddress(string memory network)
    internal
    pure
    returns (function(address) returns (string memory))
  {
    if (keccak256(abi.encode(network)) == keccak256(abi.encode(PermissionsData.ARB_ID)))
      return _identifyAddressArb;
    if (keccak256(abi.encode(network)) == keccak256(abi.encode(PermissionsData.OP_ID)))
      return _identifyAddressOp;

    revert('_chooseIdentifyAddress(). INVALID_NETWORK');
  }

  function _identifyAddressArb(address who) internal pure returns (string memory) {
    return _identifyAddress(who, PermissionsData._getKnownAccountsArb());
  }

  function _identifyAddressOp(address who) internal pure returns (string memory) {
    return _identifyAddress(who, PermissionsData._getKnownAccountsOp());
  }

  function _identifyAddress(address who, PermissionsData.PermissionHolder[] memory knownAccounts)
    internal
    pure
    returns (string memory)
  {
    for (uint256 i = 0; i < knownAccounts.length; i++) {
      if (who == knownAccounts[i].who)
        return string.concat('**', knownAccounts[i].name, '**', ' ( ', vm.toString(who), ' )');
    }
    return string.concat('**Unknown Account**', ' ( ', vm.toString(who), ' )');
  }

  function buildMDOneElRow(string memory description, string memory value)
    internal
    pure
    returns (string memory)
  {
    return string.concat(' | ', description, ' | ', value, ' | ');
  }

  function buildMDMultipleElRow(string memory description, string[] memory values)
    internal
    pure
    returns (string memory)
  {
    string memory acc = '';
    for (uint256 i = 0; i < values.length; i++) {
      acc = string.concat(acc, ' ', values[i]);
    }
    return buildMDOneElRow(description, acc);
  }

  function _writePermissionsTable(
    string memory networkIdentifier,
    string memory path,
    PermissionsData.AavePermissionsSources memory poolSources,
    address[] memory candidatesToRoles
  ) internal {
    vm.writeLine(path, string.concat('# Permissions on Aave v3 ', networkIdentifier, '\n'));
    vm.writeLine(path, string.concat('| Permission | Who? |'));
    vm.writeLine(path, '|---|---|');

    function(address) returns (string memory) _identifyAddressOnNetwork = _chooseIdentifyAddress(
      networkIdentifier
    );

    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner of addresses provider',
        _identifyAddressOnNetwork(IOwnable(poolSources.addressesProvider).owner())
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner of addresses provider registry',
        _identifyAddressOnNetwork(IOwnable(poolSources.addressesProviderRegistry).owner())
      )
    );

    vm.writeLine(
      path,
      buildMDOneElRow(
        'aclAdmin on addresses provider',
        _identifyAddressOnNetwork(
          IPoolAddressesProvider(poolSources.addressesProvider).getACLAdmin()
        )
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner repay collateral adapter',
        _identifyAddressOnNetwork(IOwnable(poolSources.repayCollateralAdapter).owner())
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner swap collateral adapter',
        _identifyAddressOnNetwork(IOwnable(poolSources.swapCollateralAdapter).owner())
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner of wrapped weth gateway',
        _identifyAddressOnNetwork(IOwnable(poolSources.wrappedTokenGateway).owner())
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner of Emission Manager',
        _identifyAddressOnNetwork(IOwnable(poolSources.emissionManager).owner())
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Owner of Controller of Collector',
        _identifyAddressOnNetwork(IOwnable(poolSources.controllerOfCollector).owner())
      )
    );
    vm.writeLine(
      path,
      buildMDOneElRow(
        'Proxy admin of Collector',
        _identifyAddressOnNetwork(
          ProxyHelpers.getInitializableAdminUpgradeabilityProxyAdmin(vm, poolSources.collector)
        )
      )
    );

    string[] memory poolAdminValues = new string[](candidatesToRoles.length);
    string[] memory emergencyAdminValues = new string[](candidatesToRoles.length);
    string[] memory superAdminValues = new string[](candidatesToRoles.length);

    for (uint256 i = 0; i < candidatesToRoles.length; i++) {
      poolAdminValues[i] = (IACLManager(poolSources.aclManager).isPoolAdmin(candidatesToRoles[i]))
        ? string.concat(' ', _identifyAddressOnNetwork(candidatesToRoles[i]))
        : '';
      emergencyAdminValues[i] = (
        IACLManager(poolSources.aclManager).isEmergencyAdmin(candidatesToRoles[i])
      )
        ? string.concat(' ', _identifyAddressOnNetwork(candidatesToRoles[i]))
        : '';
      superAdminValues[i] = (
        IACLManager(poolSources.aclManager).hasRole(
          AaveV3Arbitrum.ACL_MANAGER.DEFAULT_ADMIN_ROLE(),
          candidatesToRoles[i]
        )
      )
        ? string.concat(' ', _identifyAddressOnNetwork(candidatesToRoles[i]))
        : '';
    }
    vm.writeLine(path, buildMDMultipleElRow('POOL_ADMIN', poolAdminValues));
    vm.writeLine(path, buildMDMultipleElRow('EMERGENCY_ADMIN', emergencyAdminValues));
    vm.writeLine(path, buildMDMultipleElRow('DEFAULT_ADMIN_ROLE', superAdminValues));

    vm.writeLine(path, '\n');
  }
}

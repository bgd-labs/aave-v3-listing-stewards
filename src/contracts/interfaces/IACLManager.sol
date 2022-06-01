// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.10;

/**
 * @title IACLManager
 * @author Aave
 * @notice Defines the basic interface for the ACL Manager
 **/
interface IACLManager {
    function ASSET_LISTING_ADMIN_ROLE() external view returns (bytes32);

    function RISK_ADMIN_ROLE() external view returns (bytes32);

    function addAssetListingAdmin(address admin) external;

    function addRiskAdmin(address admin) external;

    function renounceRole(bytes32 role, address account) external;
}

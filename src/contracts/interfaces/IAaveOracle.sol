// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.10;

/**
 * @title IAaveOracle
 * @author Aave
 * @notice Defines the basic interface for the Aave Oracle
 */
interface IAaveOracle {
    /**
     * @notice Sets or replaces price sources of assets
     * @param assets The addresses of the assets
     * @param sources The addresses of the price sources
     */
    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IsAVAXWithRate {
    /**
     * @return The amount of AVAX that corresponds to `shareAmount` token shares.
     */
    function getPooledAvaxByShares(uint256 shareAmount)
        external
        view
        returns (uint256);
}

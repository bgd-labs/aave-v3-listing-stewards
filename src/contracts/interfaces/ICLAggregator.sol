// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ICLAggregator {
    function latestAnswer() external view returns (int256);
}

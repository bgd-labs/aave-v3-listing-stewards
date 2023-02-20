// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward sets configure reserve as collateral for Link.e and awavx on AAVE V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xbe3ff894ff9a979846b45e0fece4368245f61fa1d449d3761a3990b8da4aa6d7
 * - Dicussion: https://governance.aave.com/t/arc-chaos-labs-risk-parameter-updates-aave-v3-avalanche-2023-02-07/11603
 */
contract AaveV3AvaParamsSteward is StewardBase {
    
    address public constant LINKe = 0x5947BB275c521040051D82396192181b413227A3;
    address public constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;


    uint256 public constant LINKe_LIQ_THRESHOLD	 = 6800; // 68%
    uint256 public constant LINKe_LTV = 5300; // 53%
    uint256 public constant LINKe_LIQ_BONUS = 10750; // 7.5% as set today

    uint256 public constant WAVAX_LIQ_THRESHOLD = 7300; // 73%
    uint256 public constant WAVAX_LTV = 6800; // 68%
    uint256 public constant WAVAX_LIQ_BONUS = 11000; // 10% as set today

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;


        configurator.configureReserveAsCollateral(
            LINKe,
            LINKe_LTV,
            LINKe_LIQ_THRESHOLD,
            LINKe_LIQ_BONUS
        );


        configurator.configureReserveAsCollateral(
            WAVAX,
            WAVAX_LTV,
            WAVAX_LIQ_THRESHOLD,
            WAVAX_LIQ_BONUS
        );

    }
}

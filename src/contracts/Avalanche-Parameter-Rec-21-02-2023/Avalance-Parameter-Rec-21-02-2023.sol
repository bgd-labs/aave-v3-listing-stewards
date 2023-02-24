// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import '../common/StewardBase.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward sets configure reserve as collateral for Link.e and wAVAX on AAVE V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xbe3ff894ff9a979846b45e0fece4368245f61fa1d449d3761a3990b8da4aa6d7
 * - Dicussion: https://governance.aave.com/t/arc-chaos-labs-risk-parameter-updates-aave-v3-avalanche-2023-02-07/11603
 */
contract AaveV3AvaParamsSteward is StewardBase {
    
    address public constant LINKe = AaveV3AvalancheAssets.LINKe_UNDERLYING;
    address public constant WAVAX = AaveV3AvalancheAssets.WAVAX_UNDERLYING;


    uint256 public constant LINKe_LIQ_THRESHOLD	 = 6800; // 68%
    uint256 public constant LINKe_LTV = 5300; // 53%
    uint256 public constant LINKe_LIQ_BONUS = 10750; // 7.5%

    uint256 public constant WAVAX_LIQ_THRESHOLD = 7300; // 73%
    uint256 public constant WAVAX_LTV = 6800; // 68%
    uint256 public constant WAVAX_LIQ_BONUS = 11000; // 10%


    address public constant SAVAX = AaveV3AvalancheAssets.sAVAX_UNDERLYING;

    uint256 public constant SAVAX_CAP = 2_000_000;

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        AaveV3Avalanche.POOL_CONFIGURATOR.configureReserveAsCollateral(
            LINKe,
            LINKe_LTV,
            LINKe_LIQ_THRESHOLD,
            LINKe_LIQ_BONUS
        );


        AaveV3Avalanche.POOL_CONFIGURATOR.configureReserveAsCollateral(
            WAVAX,
            WAVAX_LTV,
            WAVAX_LIQ_THRESHOLD,
            WAVAX_LIQ_BONUS
        );


        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(SAVAX, SAVAX_CAP);


    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward sets the liquidation bonus for WAXAX
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xab2381e2fcda147ec0ab8417a09c0a6188fce034c12d0c0c42a43b8cbbea8db4
 * - Dicussion: https://governance.aave.com/t/arc-gauntlet-risk-parameter-updates-for-avax-v3-and-op-v3-2023-02-16/11940
 */
contract AaveV3AvaRiskParamsSteward is StewardBase {
    address public constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;

    uint256 public constant WAVAX_CURRENT_LIQ_THRESHHOLD = 7000;
    uint256 public constant WAVAX_CURRENT_LTV = 6500;

    // previous value: 11000
    uint256 public constant WAVAX_NEW_LIQ_BONUS = 10920;

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        AaveV3Avalanche.POOL_CONFIGURATOR.configureReserveAsCollateral({
            asset: WAVAX,
            ltv: WAVAX_CURRENT_LTV,
            liquidationThreshold: WAVAX_CURRENT_LIQ_THRESHHOLD,
            liquidationBonus: WAVAX_NEW_LIQ_BONUS
        });
    }
}

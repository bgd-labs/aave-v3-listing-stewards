// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '../common/StewardBase.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveAddressBook.sol';

/**
 * @dev One-time-use helper contract to be used by Aave Guardians (Gnosis Safe generally).
 * @dev This Steward enables sUSD as collateral on Aave V3 Optimism, adjusts the supply cap and changes the rate strategy.
 * - The action is approved by the Guardian by just sending the necessary permissions to this contract.
 * - The permissions needed in this case are: risk admin.
 * - The contracts renounces to the permissions after the action.
 * - The contract "burns" the ownership after the action.
 * - Parameter snapshot: https://snapshot.org/#/aave.eth/proposal/Qmem5k8zotXSnV2mm3WJXqb8HmBoT8m2URzZCq3X8igHAm
 */
contract AaveV3OptimismEnableCollateralSteward is StewardBase {
    // **************************
    // Asset to change config from (SUSD)
    // **************************

    address public constant SUSD = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;
    address public constant RATE_STRATEGY =
        0xA9F3C3caE095527061e6d270DBE163693e6fda9D;
    uint256 public constant LTV = 6000; // 60%
    uint256 public constant LIQ_THRESHOLD = 7500; // 75%
    uint256 public constant LIQ_BONUS = 10500; // 5%
    uint256 public constant SUPPLY_CAP = 10_000_000; // 10'000'000 sUSD

    function updateSUSDConfig()
        external
        withRennounceOfAllAavePermissions(AaveV3Optimism.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        // ------------------------------------------------
        // 1. Configuration of sUSD
        // ------------------------------------------------

        IPoolConfigurator configurator = AaveV3Optimism.POOL_CONFIGURATOR;

        configurator.setSupplyCap(SUSD, SUPPLY_CAP);

        configurator.configureReserveAsCollateral(
            SUSD,
            LTV,
            LIQ_THRESHOLD,
            LIQ_BONUS
        );

        configurator.setReserveInterestRateStrategyAddress(SUSD, RATE_STRATEGY);
    }
}

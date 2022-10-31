// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward enables BTCB as collateral on AAVE V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xa947772b3880e77a14ffc22cb30cde36332fd2f779b3f345608d96e4c6e203c2
 * - Dicussion: https://governance.aave.com/t/arc-add-support-for-btc-b-native-bitcoin-bridged-to-avalanche/8872/4 (contains conservative changes on top of snapshot)
 */
contract AaveV3AvaRiskParameterUpdate is StewardBase {
    // **************************
    // Parameters being set
    // **************************

    uint256 public constant LTV = 7000; // 70%
    uint256 public constant LIQ_THRESHOLD = 7500; // 75%
    uint256 public constant LIQ_BONUS = 10650; // 6.5%

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        // ----------------------------
        // 1. Step 1
        // ----------------------------

        // address[] memory assets = new address[](1);
        // assets[0] = BTCB;
        // address[] memory sources = new address[](1);
        // sources[0] = PRICE_FEED_BTCB;

        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        // configurator.configureReserveAsCollateral(
        //     BTCB,
        //     LTV,
        //     LIQ_THRESHOLD,
        //     LIQ_BONUS
        // );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// TODO document better
interface IGenericV3ListingEngine {
    struct PoolContext {
        string networkName;
        string networkAbbreviation;
    }

    struct Listing {
        address asset;
        string assetSymbol;
        address priceFeed;
        address rateStrategy; // Mandatory, no matter if enabled for borrowing or not
        bool enabledToBorrow;
        bool stableRateModeEnabled; // Only considered is enabledToBorrow == true
        bool borrowableInIsolation; // Only considered is enableToBorrow == true
        uint256 LTV; // Only considered if liqThreshold > 0
        uint256 liqThreshold; // If `0`, the asset will not be enabled as collateral
        uint256 liqBonus; // Only considered if liqThreshold > 0
        uint256 reserveFactor; // Only considered if enabledToBorrow == true
        uint256 supplyCap; // Always configured
        uint256 borrowCap; // Always configured, no matter if enabled for borrowing or not
        uint256 debtCeiling; // Only considered if liqThreshold > 0
        uint256 liqProtocolFee; // Only considered if liqThreshold > 0
    }

    struct AssetsConfig {
        address[] ids;
        Basic[] basics;
        Borrow[] borrows;
        Collateral[] collaterals;
        Caps[] caps;
    }

    struct Basic {
        string assetSymbol;
        address priceFeed;
        address rateStrategy; // Mandatory, no matter if enabled for borrowing or not
    }

    struct Borrow {
        bool enabledToBorrow;
        bool stableRateModeEnabled; // Only considered is enabledToBorrow == true
        bool borrowableInIsolation; // Only considered is enableToBorrow == true
        uint256 reserveFactor; // Only considered if enabledToBorrow == true
    }

    struct Collateral {
        uint256 LTV; // Only considered if liqThreshold > 0
        uint256 liqThreshold; // If `0`, the asset will not be enabled as collateral
        uint256 liqBonus; // Only considered if liqThreshold > 0
        uint256 debtCeiling; // Only considered if liqThreshold > 0
        uint256 liqProtocolFee; // Only considered if liqThreshold > 0
    }

    struct Caps {
        uint256 supplyCap; // Always configured
        uint256 borrowCap; // Always configured, no matter if enabled for borrowing or not
    }

    function listAssets(PoolContext memory context, Listing[] memory listings)
        external;
}

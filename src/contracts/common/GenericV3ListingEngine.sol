// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC20} from '../interfaces/IERC20.sol';
import {IPoolConfigurator, IAaveOracle, ConfiguratorInputTypes} from 'aave-address-book/AaveV3.sol';

/**
 * @dev Helper smart contract implementing a generalized Aave v3 listing flow for a set of assets
 * Assumptions:
 * - Only one a/v/s token implementation for all assets
 * - Only one RewardsController for all assets
 * - Only one Collector for all assets
 * @author BGD Labs
 */
abstract contract GenericV3ListingEngine {
    struct ListingConfig {
        address asset;
        string aTokenName;
        string aTokenSymbol;
        string vTokenName;
        string vTokenSymbol;
        string sTokenName;
        string sTokenSymbol;
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

    IPoolConfigurator public immutable POOL_CONFIGURATOR;
    IAaveOracle public immutable ORACLE;
    address public immutable ATOKEN_IMPL;
    address public immutable VTOKEN_IMPL;
    address public immutable STOKEN_IMPL;
    address public immutable REWARDS_CONTROLLER;
    address public immutable COLLECTOR;

    constructor(
        address configurator,
        address oracle,
        address aTokenImpl,
        address vTokenImpl,
        address sTokenImpl,
        address rewardsController,
        address collector
    ) {
        POOL_CONFIGURATOR = IPoolConfigurator(configurator);
        ORACLE = IAaveOracle(oracle);
        ATOKEN_IMPL = aTokenImpl;
        VTOKEN_IMPL = vTokenImpl;
        STOKEN_IMPL = sTokenImpl;
        REWARDS_CONTROLLER = rewardsController;
        COLLECTOR = collector;
    }

    function _listAssets(ListingConfig[] memory configs) internal {
        require(configs.length != 0, 'AT_LEAST_ONE_ASSET_REQUIRED');

        _setPriceFeeds(configs);

        _initAssets(configs);

        _configureCaps(configs);

        _configBorrowSide(configs);

        _configCollateralSide(configs);
    }

    function _setPriceFeeds(ListingConfig[] memory configs) internal {
        address[] memory assets = new address[](configs.length);
        address[] memory sources = new address[](configs.length);

        for (uint256 i = 0; i < configs.length; i++) {
            require(
                configs[i].priceFeed != address(0),
                'PRICE_FEED_ALWAYS_REQUIRED'
            );
            assets[i] = configs[i].asset;
            sources[i] = configs[i].priceFeed;
        }

        ORACLE.setAssetSources(assets, sources);
    }

    function _initAssets(ListingConfig[] memory configs) internal {
        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                configs.length
            );
        for (uint256 i = 0; i < configs.length; i++) {
            initReserveInputs[i] = ConfiguratorInputTypes.InitReserveInput({
                aTokenImpl: ATOKEN_IMPL,
                stableDebtTokenImpl: STOKEN_IMPL,
                variableDebtTokenImpl: VTOKEN_IMPL,
                underlyingAssetDecimals: IERC20(configs[i].asset).decimals(),
                interestRateStrategyAddress: configs[i].rateStrategy,
                underlyingAsset: configs[i].asset,
                treasury: COLLECTOR,
                incentivesController: REWARDS_CONTROLLER,
                aTokenName: configs[i].aTokenName,
                aTokenSymbol: configs[i].aTokenSymbol,
                variableDebtTokenName: configs[i].vTokenName,
                variableDebtTokenSymbol: configs[i].vTokenSymbol,
                stableDebtTokenName: configs[i].sTokenName,
                stableDebtTokenSymbol: configs[i].sTokenSymbol,
                params: bytes('')
            });
        }
        POOL_CONFIGURATOR.initReserves(initReserveInputs);
    }

    function _configureCaps(ListingConfig[] memory configs) internal {
        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].supplyCap != 0) {
                POOL_CONFIGURATOR.setSupplyCap(
                    configs[i].asset,
                    configs[i].supplyCap
                );
            }

            if (configs[i].borrowCap != 0) {
                POOL_CONFIGURATOR.setBorrowCap(
                    configs[i].asset,
                    configs[i].borrowCap
                );
            }
        }
    }

    function _configCollateralSide(ListingConfig[] memory configs) internal {
        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].liqThreshold != 0) {
                POOL_CONFIGURATOR.configureReserveAsCollateral(
                    configs[i].asset,
                    configs[i].LTV,
                    configs[i].liqThreshold,
                    10000 + configs[i].liqBonus // Opinionated, seems more correct to define liqBonus as 5_00 for 5%
                );

                POOL_CONFIGURATOR.setLiquidationProtocolFee(
                    configs[i].asset,
                    configs[i].liqProtocolFee
                );

                if (configs[i].debtCeiling != 0) {
                    POOL_CONFIGURATOR.setDebtCeiling(
                        configs[i].asset,
                        configs[i].debtCeiling
                    );
                }
            }
        }
    }

    function _configBorrowSide(ListingConfig[] memory configs) internal {
        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].enabledToBorrow) {
                POOL_CONFIGURATOR.setReserveBorrowing(configs[i].asset, true);

                // If enabled to borrow, the reserve factor should always be configured
                require(
                    configs[i].reserveFactor > 0,
                    'RESERVE_FACTOR_REQUIRED'
                );
                POOL_CONFIGURATOR.setReserveFactor(
                    configs[i].asset,
                    configs[i].reserveFactor
                );

                // TODO add flashloanable

                if (configs[i].stableRateModeEnabled) {
                    POOL_CONFIGURATOR.setReserveStableRateBorrowing(
                        configs[i].asset,
                        true
                    );
                }

                if (configs[i].borrowableInIsolation) {
                    POOL_CONFIGURATOR.setBorrowableInIsolation(
                        configs[i].asset,
                        true
                    );
                }
            }
        }
    }

    /// @dev Children contract should define the set of assets to list
    function _getAllConfigs() internal virtual returns (ListingConfig[] memory);
}

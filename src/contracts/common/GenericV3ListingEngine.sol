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

    IPoolConfigurator public immutable POOL_CONFIGURATOR;
    IAaveOracle public immutable ORACLE;
    address public immutable ATOKEN_IMPL;
    address public immutable VTOKEN_IMPL;
    address public immutable STOKEN_IMPL;
    address public immutable REWARDS_CONTROLLER;
    address public immutable COLLECTOR;
    string public constant NETWORK_NAME = 'Ethereum';
    string public constant NETWORK_PREFIX = 'Eth';

    constructor(
        address configurator,
        address oracle,
        address aTokenImpl,
        address vTokenImpl,
        address sTokenImpl,
        address rewardsController,
        address collector
    ) {
        require(configurator != address(0), 'ONLY_NONZERO_CONFIGURATOR');
        require(oracle != address(0), 'ONLY_NONZERO_ORACLE');
        require(aTokenImpl != address(0), 'ONLY_NONZERO_ATOKEN');
        require(vTokenImpl != address(0), 'ONLY_NONZERO_VTOKEN');
        require(sTokenImpl != address(0), 'ONLY_NONZERO_STOKEN');
        require(
            rewardsController != address(0),
            'ONLY_NONZERO_REWARDS_CONTROLLER'
        );
        require(collector != address(0), 'ONLY_NONZERO_COLLECTOR');

        POOL_CONFIGURATOR = IPoolConfigurator(configurator);
        ORACLE = IAaveOracle(oracle);
        ATOKEN_IMPL = aTokenImpl;
        VTOKEN_IMPL = vTokenImpl;
        STOKEN_IMPL = sTokenImpl;
        REWARDS_CONTROLLER = rewardsController;
        COLLECTOR = collector;
    }

    function _listAssets() internal {
        Listing[] memory listings = getAllConfigs();

        require(listings.length != 0, 'AT_LEAST_ONE_ASSET_REQUIRED');

        AssetsConfig memory configs = _repackListing(listings);

        _setPriceFeeds(configs.ids, configs.basics);

        _initAssets(configs.ids, configs.basics);

        _configureCaps(configs.ids, configs.caps);

        _configBorrowSide(configs.ids, configs.borrows);

        _configCollateralSide(configs.ids, configs.collaterals);
    }

    function _setPriceFeeds(address[] memory ids, Basic[] memory basics)
        internal
    {
        address[] memory assets = new address[](ids.length);
        address[] memory sources = new address[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            require(
                basics[i].priceFeed != address(0),
                'PRICE_FEED_ALWAYS_REQUIRED'
            );
            // TODO require that latestAnswer() returns more than 0
            assets[i] = ids[i];
            sources[i] = basics[i].priceFeed;
        }

        ORACLE.setAssetSources(assets, sources);
    }

    /// @dev mandatory configurations for any asset getting listed, including oracle config and basic init
    function _initAssets(address[] memory ids, Basic[] memory basics) internal {
        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                ids.length
            );
        for (uint256 i = 0; i < ids.length; i++) {
            uint8 decimals = IERC20(ids[i]).decimals();
            require(decimals > 0, 'INVALID_ASSET_DECIMALS');
            require(
                basics[i].rateStrategy != address(0),
                'ONLY_NONZERO_RATE_STRATEGY'
            );

            initReserveInputs[i] = ConfiguratorInputTypes.InitReserveInput({
                aTokenImpl: ATOKEN_IMPL,
                stableDebtTokenImpl: STOKEN_IMPL,
                variableDebtTokenImpl: VTOKEN_IMPL,
                underlyingAssetDecimals: decimals,
                interestRateStrategyAddress: basics[i].rateStrategy,
                underlyingAsset: ids[i],
                treasury: COLLECTOR,
                incentivesController: REWARDS_CONTROLLER,
                aTokenName: string(
                    abi.encodePacked(
                        'Aave ',
                        NETWORK_NAME,
                        ' ',
                        basics[i].assetSymbol
                    )
                ), // TODO change to string.concat
                aTokenSymbol: string(
                    abi.encodePacked('a', NETWORK_PREFIX, basics[i].assetSymbol)
                ),
                variableDebtTokenName: string(
                    abi.encodePacked(
                        'Aave ',
                        NETWORK_NAME,
                        ' Variable Debt ',
                        basics[i].assetSymbol
                    )
                ),
                variableDebtTokenSymbol: string(
                    abi.encodePacked(
                        'variableDebt',
                        NETWORK_PREFIX,
                        basics[i].assetSymbol
                    )
                ),
                stableDebtTokenName: string(
                    abi.encodePacked(
                        'Aave ',
                        NETWORK_NAME,
                        ' Stable Debt ',
                        basics[i].assetSymbol
                    )
                ),
                stableDebtTokenSymbol: string(
                    abi.encodePacked(
                        'stableDebt',
                        NETWORK_PREFIX,
                        basics[i].assetSymbol
                    )
                ),
                params: bytes('')
            });
        }
        POOL_CONFIGURATOR.initReserves(initReserveInputs);
    }

    function _configureCaps(address[] memory ids, Caps[] memory caps) internal {
        for (uint256 i = 0; i < ids.length; i++) {
            if (caps[i].supplyCap != 0) {
                POOL_CONFIGURATOR.setSupplyCap(ids[i], caps[i].supplyCap);
            }

            if (caps[i].borrowCap != 0) {
                POOL_CONFIGURATOR.setBorrowCap(ids[i], caps[i].borrowCap);
            }
        }
    }

    function _configBorrowSide(address[] memory ids, Borrow[] memory borrows)
        internal
    {
        for (uint256 i = 0; i < ids.length; i++) {
            if (borrows[i].enabledToBorrow) {
                POOL_CONFIGURATOR.setReserveBorrowing(ids[i], true);

                // If enabled to borrow, the reserve factor should always be configured and > 0
                require(
                    borrows[i].reserveFactor > 0 &&
                        borrows[i].reserveFactor <= 99_99,
                    'INVALID_RESERVE_FACTOR'
                );
                POOL_CONFIGURATOR.setReserveFactor(
                    ids[i],
                    borrows[i].reserveFactor
                );

                // TODO add flashloanable

                if (borrows[i].stableRateModeEnabled) {
                    POOL_CONFIGURATOR.setReserveStableRateBorrowing(
                        ids[i],
                        true
                    );
                }

                if (borrows[i].borrowableInIsolation) {
                    POOL_CONFIGURATOR.setBorrowableInIsolation(ids[i], true);
                }
            }
        }
    }

    function _configCollateralSide(
        address[] memory ids,
        Collateral[] memory collaterals
    ) internal {
        for (uint256 i = 0; i < ids.length; i++) {
            if (collaterals[i].liqThreshold != 0) {
                require(
                    collaterals[i].liqThreshold + collaterals[i].liqBonus <
                        100_00,
                    'INVALID_LIQ_PARAMS_ABOVE_100'
                );
                require(
                    collaterals[i].liqProtocolFee < 100_00,
                    'INVALID_LIQ_PROTOCOL_FEE'
                );

                POOL_CONFIGURATOR.configureReserveAsCollateral(
                    ids[i],
                    collaterals[i].LTV,
                    collaterals[i].liqThreshold,
                    100_00 + collaterals[i].liqBonus // Opinionated, seems more correct to define liqBonus as 5_00 for 5%
                );

                POOL_CONFIGURATOR.setLiquidationProtocolFee(
                    ids[i],
                    collaterals[i].liqProtocolFee
                );

                if (collaterals[i].debtCeiling != 0) {
                    POOL_CONFIGURATOR.setDebtCeiling(
                        ids[i],
                        collaterals[i].debtCeiling
                    );
                }
            }
        }
    }

    function _repackListing(Listing[] memory listings)
        internal
        returns (AssetsConfig memory)
    {
        address[] memory ids = new address[](listings.length);
        Basic[] memory basics = new Basic[](listings.length);
        Borrow[] memory borrows = new Borrow[](listings.length);
        Collateral[] memory collaterals = new Collateral[](listings.length);
        Caps[] memory caps = new Caps[](listings.length);

        for (uint256 i = 0; i < listings.length; i++) {
            ids[i] = listings[i].asset;
            basics[i] = Basic({
                assetSymbol: listings[i].assetSymbol,
                priceFeed: listings[i].priceFeed,
                rateStrategy: listings[i].rateStrategy
            });
            borrows[i] = Borrow({
                enabledToBorrow: listings[i].enabledToBorrow,
                stableRateModeEnabled: listings[i].stableRateModeEnabled,
                borrowableInIsolation: listings[i].borrowableInIsolation,
                reserveFactor: listings[i].reserveFactor
            });
            collaterals[i] = Collateral({
                LTV: listings[i].LTV,
                liqThreshold: listings[i].liqThreshold,
                liqBonus: listings[i].liqBonus,
                debtCeiling: listings[i].debtCeiling,
                liqProtocolFee: listings[i].liqProtocolFee
            });
            caps[i] = Caps({
                supplyCap: listings[i].supplyCap,
                borrowCap: listings[i].borrowCap
            });
        }

        return
            AssetsConfig({
                ids: ids,
                basics: basics,
                borrows: borrows,
                collaterals: collaterals,
                caps: caps
            });
    }

    /// @dev Children contract should define the set of assets to list
    function getAllConfigs() public virtual returns (Listing[] memory);
}

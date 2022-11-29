// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC20} from '../interfaces/IERC20.sol';
import {IPoolConfigurator, IAaveOracle, ConfiguratorInputTypes} from 'aave-address-book/AaveV3.sol';
import {AaveV2Ethereum} from 'aave-address-book/AaveV2Ethereum.sol';

/**
 * @dev Payload smart contract for the Aave governance to:
 *   - Activate the Aave v3 Ethereum pool (un-pausing it)
 *   - List the initial assets, suggested by risk providers and pre-approved by the community
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0x288caef0d79e5883884324b90daa3c5550135ea0c78738e7ca2363243340c2da
 * - Discussion: https://governance.aave.com/t/arc-aave-v3-ethereum-deployment-assets-and-configurations/10238
 */
contract AaveV3EthereumGenesisPayload {
    struct ListingConfig {
        address asset;
        string aTokenName;
        string aTokenSymbol;
        string vTokenName;
        string vTokenSymbol;
        string sTokenName;
        string sTokenSymbol;
        address priceFeed;
        address rateStrategy;
        bool enabledToBorrow;
        uint256 LTV;
        uint256 liqThreshold;
        uint256 liqBonus;
        uint256 reserveFactor;
        uint256 supplyCap;
        uint256 borrowCap;
        uint256 liqProtocolFee;
    }

    // **************************
    // Common contracts
    // **************************

    IPoolConfigurator POOL_CONFIGURATOR = IPoolConfigurator(address(0)); // TODO
    IAaveOracle ORACLE = IAaveOracle(address(0)); // TODO

    address public constant INCENTIVES_CONTROLLER = address(0); //  TODO

    address public constant ATOKEN_IMPL = address(0); // TODO
    address public constant VDTOKEN_IMPL = address(0); // TODO
    address public constant SDTOKEN_IMPL = address(0); // TODO

    function execute() external {
        POOL_CONFIGURATOR.setPoolPause(false);
        _listWETH();
    }

    function _listWETH() internal {
        ListingConfig memory config = ListingConfig({
            asset: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            aTokenName: 'Aave Ethereum WETH',
            aTokenSymbol: 'aEthWETH',
            vTokenName: 'Aave Ethereum Variable Debt WETH',
            vTokenSymbol: 'variableDebtEthWETH',
            sTokenName: 'Aave Ethereum Stable Debt WETH',
            sTokenSymbol: 'stableDebtEthWETH',
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            rateStrategy: address(0), // TODO
            enabledToBorrow: true,
            LTV: 82_50,
            liqThreshold: 86_00,
            liqBonus: 10_500,
            reserveFactor: 10_00,
            supplyCap: 85_000,
            borrowCap: 60_000,
            liqProtocolFee: 10_00
        });

        // ------------------------------------------------
        // 1. Oracle
        // ------------------------------------------------

        require(config.priceFeed != address(0), 'INVALID_PRICE_FEED');

        address[] memory assets = new address[](1);
        assets[0] = config.asset;
        address[] memory sources = new address[](1);
        sources[0] = config.priceFeed;

        ORACLE.setAssetSources(assets, sources);

        // ------------------------------------------------
        // 2. Configs setup
        // ------------------------------------------------

        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                1
            );
        initReserveInputs[0] = ConfiguratorInputTypes.InitReserveInput({
            aTokenImpl: ATOKEN_IMPL,
            stableDebtTokenImpl: SDTOKEN_IMPL,
            variableDebtTokenImpl: VDTOKEN_IMPL,
            underlyingAssetDecimals: IERC20(config.asset).decimals(),
            interestRateStrategyAddress: config.rateStrategy,
            underlyingAsset: config.asset,
            treasury: AaveV2Ethereum.COLLECTOR,
            incentivesController: INCENTIVES_CONTROLLER,
            aTokenName: config.aTokenName,
            aTokenSymbol: config.aTokenSymbol,
            variableDebtTokenName: config.vTokenName,
            variableDebtTokenSymbol: config.vTokenSymbol,
            stableDebtTokenName: config.sTokenName,
            stableDebtTokenSymbol: config.sTokenSymbol,
            params: bytes('')
        });

        IPoolConfigurator configurator = POOL_CONFIGURATOR;

        configurator.initReserves(initReserveInputs);

        configurator.setSupplyCap(config.asset, config.supplyCap);

        configurator.setBorrowCap(config.asset, config.borrowCap);

        configurator.setReserveBorrowing(config.asset, config.enabledToBorrow);

        configurator.configureReserveAsCollateral(
            config.asset,
            config.LTV,
            config.liqThreshold,
            config.liqBonus
        );

        configurator.setReserveFactor(config.asset, config.reserveFactor);

        configurator.setLiquidationProtocolFee(
            config.asset,
            config.liqProtocolFee
        );
    }
}

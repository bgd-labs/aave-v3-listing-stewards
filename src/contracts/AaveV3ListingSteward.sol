// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IPoolConfigurator, ConfiguratorInputTypes} from './interfaces/IPoolConfigurator.sol';
import {IAaveOracle} from './interfaces/IAaveOracle.sol';
import {Ownable} from './dependencies/Ownable.sol';

contract AaveV3ListingSteward is Ownable {
    function listAssetAddingOracle(
        IPoolConfigurator configurator,
        IAaveOracle oracle,
        address priceFeed,
        ConfiguratorInputTypes.InitReserveInput calldata listingInputs
    ) external onlyOwner {
        address[] memory assets = new address[](1);
        assets[0] = listingInputs.underlyingAsset;
        address[] memory sources = new address[](1);
        sources[0] = priceFeed;

        oracle.setAssetSources(assets, sources);

        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                1
            );

        initReserveInputs[0] = ConfiguratorInputTypes.InitReserveInput({
            aTokenImpl: listingInputs.aTokenImpl,
            stableDebtTokenImpl: listingInputs.stableDebtTokenImpl,
            variableDebtTokenImpl: listingInputs.variableDebtTokenImpl,
            underlyingAssetDecimals: listingInputs.underlyingAssetDecimals,
            interestRateStrategyAddress: listingInputs
                .interestRateStrategyAddress,
            underlyingAsset: listingInputs.underlyingAsset,
            treasury: listingInputs.treasury,
            incentivesController: listingInputs.incentivesController,
            aTokenName: listingInputs.aTokenName,
            aTokenSymbol: listingInputs.aTokenSymbol,
            variableDebtTokenName: listingInputs.variableDebtTokenName,
            variableDebtTokenSymbol: listingInputs.variableDebtTokenSymbol,
            stableDebtTokenName: listingInputs.stableDebtTokenName,
            stableDebtTokenSymbol: listingInputs.stableDebtTokenSymbol,
            params: listingInputs.params
        });

        configurator.initReserves(initReserveInputs);
    }
}

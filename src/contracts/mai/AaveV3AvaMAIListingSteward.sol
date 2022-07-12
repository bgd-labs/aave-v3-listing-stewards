// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';

contract AaveV3AvaMAIListingSteward is StewardBase {
    // **************************
    // Protocol's contracts
    // **************************

    address public constant AAVE_TREASURY =
        0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0;
    address public constant INCENTIVES_CONTROLLER =
        0x929EC64c34a17401F460460D4B9390518E5B473e;

    // **************************
    // New asset being listed (MAI)
    // **************************

    address public constant UNDERLYING =
        0x3B55E45fD6bd7d4724F5c47E0d1bCaEdd059263e;
    string public constant ATOKEN_NAME = 'Aave Avalanche MAI';
    string public constant ATOKEN_SYMBOL = 'aAvaMAI';
    string public constant VDTOKEN_NAME = 'Aave Avalanche Variable Debt MAI';
    string public constant VDTOKEN_SYMBOL = 'variableDebtAvaMAI';
    string public constant SDTOKEN_NAME = 'Aave Avalanche Stable Debt MAI';
    string public constant SDTOKEN_SYMBOL = 'stableDebtAvaMAI';

    address public constant PRICE_FEED =
        0x5D1F504211c17365CA66353442a74D4435A8b778;

    address public constant ATOKEN_IMPL =
        0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B;
    address public constant VDTOKEN_IMPL =
        0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3;
    address public constant SDTOKEN_IMPL =
        0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e;
    address public constant RATE_STRATEGY =
        0xf4a0039F2d4a2EaD5216AbB6Ae4C4C3AA2dB9b82;
    uint256 public constant RESERVE_FACTOR = 1000; // 10%

    uint256 public constant SUPPLY_CAP = 10_000_000; // 10m
    uint256 public constant LIQ_PROTOCOL_FEE = 1000; // 10%

    uint8 public constant EMODE_CATEGORY = 1; // Stablecoins

    function listAssetAddingOracle()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        // ----------------------------
        // 1. New price feed on oracle
        // ----------------------------

        require(PRICE_FEED != address(0), 'INVALID_PRICE_FEED');

        address[] memory assets = new address[](1);
        assets[0] = UNDERLYING;
        address[] memory sources = new address[](1);
        sources[0] = PRICE_FEED;

        AaveV3Avalanche.ORACLE.setAssetSources(assets, sources);

        // ------------------------------------------------
        // 2. Listing of MAI, with all its configurations
        // ------------------------------------------------

        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                1
            );
        initReserveInputs[0] = ConfiguratorInputTypes.InitReserveInput({
            aTokenImpl: ATOKEN_IMPL,
            stableDebtTokenImpl: SDTOKEN_IMPL,
            variableDebtTokenImpl: VDTOKEN_IMPL,
            underlyingAssetDecimals: IERC20(UNDERLYING).decimals(),
            interestRateStrategyAddress: RATE_STRATEGY,
            underlyingAsset: UNDERLYING,
            treasury: AAVE_TREASURY,
            incentivesController: INCENTIVES_CONTROLLER,
            aTokenName: ATOKEN_NAME,
            aTokenSymbol: ATOKEN_SYMBOL,
            variableDebtTokenName: VDTOKEN_NAME,
            variableDebtTokenSymbol: VDTOKEN_SYMBOL,
            stableDebtTokenName: SDTOKEN_NAME,
            stableDebtTokenSymbol: SDTOKEN_SYMBOL,
            params: bytes('')
        });

        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        configurator.initReserves(initReserveInputs);

        configurator.setSupplyCap(UNDERLYING, SUPPLY_CAP);

        configurator.setReserveBorrowing(UNDERLYING, true);

        configurator.setReserveFactor(UNDERLYING, RESERVE_FACTOR);

        configurator.setAssetEModeCategory(UNDERLYING, EMODE_CATEGORY);

        configurator.setLiquidationProtocolFee(UNDERLYING, LIQ_PROTOCOL_FEE);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';

contract AaveV3AvaFRAXListingSteward is StewardBase {
    // **************************
    // Protocol's contracts
    // **************************

    address public constant AAVE_TREASURY =
        0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0;
    address public constant INCENTIVES_CONTROLLER =
        0x929EC64c34a17401F460460D4B9390518E5B473e;

    // **************************
    // New asset being listed (FRAX)
    // **************************

    address public constant FRAX = 0xD24C2Ad096400B6FBcd2ad8B24E7acBc21A1da64;
    string public constant FRAX_NAME = 'Aave Avalanche FRAX';
    string public constant AFRAX_SYMBOL = 'aAvaFRAX';
    string public constant VDFRAX_NAME = 'Aave Avalanche Variable Debt FRAX';
    string public constant VDFRAX_SYMBOL = 'variableDebtAvaFRAX';
    string public constant SDFRAX_NAME = 'Aave Avalanche Stable Debt FRAX';
    string public constant SDFRAX_SYMBOL = 'stableDebtAvaFRAX';

    address public constant PRICE_FEED_FRAX =
        0xbBa56eF1565354217a3353a466edB82E8F25b08e;

    address public constant ATOKEN_IMPL =
        0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B;
    address public constant VDTOKEN_IMPL =
        0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3;
    address public constant SDTOKEN_IMPL =
        0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e;
    address public constant RATE_STRATEGY =
        0xf4a0039F2d4a2EaD5216AbB6Ae4C4C3AA2dB9b82;
    uint256 public constant LTV = 7500; // 75%
    uint256 public constant LIQ_THRESHOLD = 8000; // 80%
    uint256 public constant RESERVE_FACTOR = 1000; // 10%

    uint256 public constant LIQ_BONUS = 10500; // 5%
    uint256 public constant SUPPLY_CAP = 50_000_000; // 50m FRAX
    uint256 public constant LIQ_PROTOCOL_FEE = 1000; // 10%

    uint256 public constant DEBT_CEILING = 2_000_000_00; // 2m

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

        require(PRICE_FEED_FRAX != address(0), 'INVALID_PRICE_FEED');

        address[] memory assets = new address[](1);
        assets[0] = FRAX;
        address[] memory sources = new address[](1);
        sources[0] = PRICE_FEED_FRAX;

        AaveV3Avalanche.ORACLE.setAssetSources(assets, sources);

        // ------------------------------------------------
        // 2. Listing of FRAX, with all its configurations
        // ------------------------------------------------

        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                1
            );
        initReserveInputs[0] = ConfiguratorInputTypes.InitReserveInput({
            aTokenImpl: ATOKEN_IMPL,
            stableDebtTokenImpl: SDTOKEN_IMPL,
            variableDebtTokenImpl: VDTOKEN_IMPL,
            underlyingAssetDecimals: IERC20(FRAX).decimals(),
            interestRateStrategyAddress: RATE_STRATEGY,
            underlyingAsset: FRAX,
            treasury: AAVE_TREASURY,
            incentivesController: INCENTIVES_CONTROLLER,
            aTokenName: FRAX_NAME,
            aTokenSymbol: AFRAX_SYMBOL,
            variableDebtTokenName: VDFRAX_NAME,
            variableDebtTokenSymbol: VDFRAX_SYMBOL,
            stableDebtTokenName: SDFRAX_NAME,
            stableDebtTokenSymbol: SDFRAX_SYMBOL,
            params: bytes('')
        });

        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        configurator.initReserves(initReserveInputs);

        configurator.setSupplyCap(FRAX, SUPPLY_CAP);

        configurator.setDebtCeiling(FRAX, DEBT_CEILING);

        configurator.setReserveBorrowing(FRAX, true);

        configurator.setBorrowableInIsolation(FRAX, true);

        configurator.configureReserveAsCollateral(
            FRAX,
            LTV,
            LIQ_THRESHOLD,
            LIQ_BONUS
        );

        configurator.setAssetEModeCategory(FRAX, EMODE_CATEGORY);

        configurator.setReserveFactor(FRAX, RESERVE_FACTOR);

        configurator.setLiquidationProtocolFee(FRAX, LIQ_PROTOCOL_FEE);
    }
}

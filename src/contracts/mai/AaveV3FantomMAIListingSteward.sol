// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Fantom} from 'aave-address-book/AaveAddressBook.sol';


/**
 * @dev This steward lists MAI (miMATIC) as borrowing asset on Aave V3 Fantom
 * - Parameter snapshot: https://snapshot.org/#/aave.eth/proposal/0x751b8fd1c77677643e419d327bdf749c29ccf0a0269e58ed2af0013843376051
 * The proposal is, as agreed with the proposer, more conservative than the approved parameters:
 * - Not enabled as collateral initially and thus not be isolated / have a debt ceiling.
 * - The eMode lq treshold will be 97.5, instead of the suggested 98% as the parameters are per emode not per asset
 * - Adding a 10M supply cap.
 */
contract AaveV3FantomMAIListingSteward is StewardBase {
    // **************************
    // Protocol's contracts
    // **************************

    address public constant AAVE_TREASURY =
        0xBe85413851D195fC6341619cD68BfDc26a25b928;
    address public constant INCENTIVES_CONTROLLER =
        0x929EC64c34a17401F460460D4B9390518E5B473e;

    // **************************
    // New asset being listed (MAI)
    // **************************

    address public constant UNDERLYING =
        0xfB98B335551a418cD0737375a2ea0ded62Ea213b;
    string public constant ATOKEN_NAME = 'Aave Fantom MAI';
    string public constant ATOKEN_SYMBOL = 'aFanMAI';
    string public constant VDTOKEN_NAME = 'Aave Fantom Variable Debt MAI';
    string public constant VDTOKEN_SYMBOL = 'variableDebtFanMAI';
    string public constant SDTOKEN_NAME = 'Aave Fantom Stable Debt MAI';
    string public constant SDTOKEN_SYMBOL = 'stableDebtFanMAI';

    address public constant PRICE_FEED =
        0x827863222c9C603960dE6FF2c0dD58D457Dcc363;

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
        withRennounceOfAllAavePermissions(AaveV3Fantom.ACL_MANAGER)
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

        AaveV3Fantom.ORACLE.setAssetSources(assets, sources);

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

        IPoolConfigurator configurator = AaveV3Fantom.POOL_CONFIGURATOR;

        configurator.initReserves(initReserveInputs);

        configurator.setSupplyCap(UNDERLYING, SUPPLY_CAP);

        configurator.setReserveBorrowing(UNDERLYING, true);

        configurator.setReserveFactor(UNDERLYING, RESERVE_FACTOR);

        configurator.setAssetEModeCategory(UNDERLYING, EMODE_CATEGORY);

        configurator.setLiquidationProtocolFee(UNDERLYING, LIQ_PROTOCOL_FEE);
    }
}

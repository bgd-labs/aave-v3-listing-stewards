// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IPoolConfigurator, ConfiguratorInputTypes} from './interfaces/IPoolConfigurator.sol';
import {IACLManager} from './interfaces/IACLManager.sol';
import {IAaveOracle} from './interfaces/IAaveOracle.sol';
import {Ownable} from './dependencies/Ownable.sol';

contract AaveV3FRAXListingSteward is Ownable {
    // **************************
    // Protocol's contracts
    // **************************

    IPoolConfigurator public constant CONFIGURATOR =
        IPoolConfigurator(0x8145eddDf43f50276641b55bd3AD95944510021E);
    IAaveOracle public constant ORACLE =
        IAaveOracle(0xEBd36016B3eD09D4693Ed4251c67Bd858c3c7C9C);
    address public constant AAVE_AVALANCHE_TREASURY =
        0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0;
    address public constant INCENTIVES_CONTROLLER =
        0x929EC64c34a17401F460460D4B9390518E5B473e;
    IACLManager public constant ACL_MANAGER =
        IACLManager(0xa72636CbcAa8F5FF95B2cc47F3CDEe83F3294a0B);

    // **************************
    // New asset being listed (FRAX)
    // **************************

    address public constant FRAX = 0xD24C2Ad096400B6FBcd2ad8B24E7acBc21A1da64;
    uint8 public constant FRAX_DECIMALS = 6;
    string public constant FRAX_NAME = 'Aave Avalanche FRAX';
    string public constant AFRAX_SYMBOL = 'aAvaFrax';
    string public constant VDFRAX_NAME = 'Aave Avalanche Variable Debt FRAX';
    string public constant VDFRAX_SYMBOL = 'vraibleDebtAaveFRAX';
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
    uint256 public constant LIQ_THRESHOLD = 8000; // 800%
    uint256 public constant RESERVE_FACTOR = 500; // 5%

    uint256 public constant LIQ_BONUS = 11000; // 10% // NOT DEFINED
    uint256 public constant SUPPLY_CAP = 500_000; // NOT DEFINED
    uint256 public constant LIQ_PROTOCOL_FEE = 1000; // NOT DEFINED

    function listAssetAddingOracle() external onlyOwner {
        // ----------------------------
        // 1. New price feed on oracle
        // ----------------------------

        address[] memory assets = new address[](1);
        assets[0] = FRAX;
        address[] memory sources = new address[](1);
        sources[0] = PRICE_FEED_FRAX;

        ORACLE.setAssetSources(assets, sources);

        // ------------------------------------------------
        // 3. Listing of sAVAX, with all its configurations
        // ------------------------------------------------

        ConfiguratorInputTypes.InitReserveInput[]
            memory initReserveInputs = new ConfiguratorInputTypes.InitReserveInput[](
                1
            );
        initReserveInputs[0] = ConfiguratorInputTypes.InitReserveInput({
            aTokenImpl: ATOKEN_IMPL,
            stableDebtTokenImpl: SDTOKEN_IMPL,
            variableDebtTokenImpl: VDTOKEN_IMPL,
            underlyingAssetDecimals: FRAX_DECIMALS,
            interestRateStrategyAddress: RATE_STRATEGY,
            underlyingAsset: FRAX,
            treasury: AAVE_AVALANCHE_TREASURY,
            incentivesController: INCENTIVES_CONTROLLER,
            aTokenName: FRAX_NAME,
            aTokenSymbol: AFRAX_SYMBOL,
            variableDebtTokenName: VDFRAX_NAME,
            variableDebtTokenSymbol: VDFRAX_SYMBOL,
            stableDebtTokenName: SDFRAX_NAME,
            stableDebtTokenSymbol: SDFRAX_SYMBOL,
            params: bytes('') // TODO
        });

        CONFIGURATOR.initReserves(initReserveInputs);

        CONFIGURATOR.setSupplyCap(FRAX, SUPPLY_CAP);
        // CONFIGURATOR.setDebtCeiling(FRAX, newDebtCeiling);

        CONFIGURATOR.configureReserveAsCollateral(
            FRAX,
            LTV,
            LIQ_THRESHOLD,
            LIQ_BONUS
        );

        CONFIGURATOR.setAssetEModeCategory(FRAX, 1);

        CONFIGURATOR.setReserveFactor(FRAX, RESERVE_FACTOR);

        CONFIGURATOR.setLiquidationProtocolFee(FRAX, LIQ_PROTOCOL_FEE);

        // ---------------------------------------------------------------
        // 4. This contract renounces to both listing and risk admin roles
        // ---------------------------------------------------------------

        ACL_MANAGER.renounceRole(
            ACL_MANAGER.ASSET_LISTING_ADMIN_ROLE(),
            address(this)
        );
        ACL_MANAGER.renounceRole(ACL_MANAGER.RISK_ADMIN_ROLE(), address(this));
    }
}

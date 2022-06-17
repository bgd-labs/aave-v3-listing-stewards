// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import {IPoolConfigurator, ConfiguratorInputTypes} from '../interfaces/IPoolConfigurator.sol';
import {IACLManager} from '../interfaces/IACLManager.sol';
import {IAaveOracle} from '../interfaces/IAaveOracle.sol';
import {Ownable} from '../dependencies/Ownable.sol';
import {sAVAXOracleAdapter} from './sAVAXOracleAdapter.sol';

/**
 * @dev One-time-use helper contract to be used by Aave Guardians (Gnosis Safe generally) to list new assets:
 * - Guardian should be the `owner`, for extra security, even if theoretically `listAssetAddingOracle` could be open.
 * - It pre-requires to have risk admin and asset listings role.
 * - It lists a new price feed on the AaveOracle.
 * - Adds a new e-mode.
 * - Lists the asset using the PoolConfigurator.
 * - Renounces to risk admin and asset listing roles.
 */
contract AaveV3SAVAXListingSteward is Ownable {
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
    // New eMode category (AVAX-like)
    // **************************

    uint8 public constant NEW_EMODE_ID = 2;
    uint16 public constant NEW_EMODE_LTV = 9250; // 92.5%
    uint16 public constant NEW_EMODE_LIQ_THRESHOLD = 9500; // 95%
    uint16 public constant NEW_EMODE_LIQ_BONUS = 10100; // 1%
    address public constant NEW_EMODE_ORACLE = address(0); // No custom oracle
    string public constant NEW_EMODE_LABEL = 'AVAX correlated';

    // **************************
    // New asset being listed (SAVAX)
    // **************************

    address public constant SAVAX = 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE;
    uint8 public constant SAVAX_DECIMALS = 18;
    string public constant ASAVAX_NAME = 'Aave Avalanche sAVAX';
    string public constant ASAVAX_SYMBOL = 'aAvasAVAX';
    string public constant VDSAVAX_NAME = 'Aave Avalanche Variable Debt sAVAX';
    string public constant VDSAVAX_SYMBOL = 'variableDebtAvasAVAX';
    string public constant SDSAVAX_NAME = 'Aave Avalanche Stable Debt sAVAX';
    string public constant SDSAVAX_SYMBOL = 'stableDebtAvasAVAX';
    address public constant ATOKEN_IMPL =
        0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B;
    address public constant VDTOKEN_IMPL =
        0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3;
    address public constant SDTOKEN_IMPL =
        0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e;
    address public constant RATE_STRATEGY =
        0x79a906e8c998d2fb5C5D66d23c4c5416Fe0168D6;
    address public constant SAVAX_PRICE_FEED =
        0xc9245871D69BF4c36c6F2D15E0D68Ffa883FE1A7;
    uint256 public constant LTV = 2000; // 20%
    uint256 public constant LIQ_THRESHOLD = 3000; // 30%
    uint256 public constant LIQ_BONUS = 11000; // 10%
    uint256 public constant SUPPLY_CAP = 500_000; // ~$8.8m at price of 17/06/2022
    uint256 public constant RESERVE_FACTOR = 1000; // 10%
    uint256 public constant LIQ_PROTOCOL_FEE = 1000; // 10%

    function listAssetAddingOracle() external onlyOwner {
        // ----------------------------
        // 1. New price feed on oracle
        // ----------------------------

        require(SAVAX_PRICE_FEED != address(0), 'INVALID_PRICE_FEED');

        address[] memory assets = new address[](1);
        assets[0] = SAVAX;
        address[] memory sources = new address[](1);
        sources[0] = SAVAX_PRICE_FEED;

        ORACLE.setAssetSources(assets, sources);

        // -----------------------------------------
        // 2. Creation of new eMode on the Aave Pool
        // -----------------------------------------

        CONFIGURATOR.setEModeCategory(
            NEW_EMODE_ID,
            NEW_EMODE_LTV,
            NEW_EMODE_LIQ_THRESHOLD,
            NEW_EMODE_LIQ_BONUS,
            address(0),
            NEW_EMODE_LABEL
        );

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
            underlyingAssetDecimals: SAVAX_DECIMALS,
            interestRateStrategyAddress: RATE_STRATEGY,
            underlyingAsset: SAVAX,
            treasury: AAVE_AVALANCHE_TREASURY,
            incentivesController: INCENTIVES_CONTROLLER,
            aTokenName: ASAVAX_NAME,
            aTokenSymbol: ASAVAX_SYMBOL,
            variableDebtTokenName: VDSAVAX_NAME,
            variableDebtTokenSymbol: VDSAVAX_SYMBOL,
            stableDebtTokenName: SDSAVAX_NAME,
            stableDebtTokenSymbol: SDSAVAX_SYMBOL,
            params: bytes('')
        });

        CONFIGURATOR.initReserves(initReserveInputs);

        CONFIGURATOR.setSupplyCap(SAVAX, SUPPLY_CAP);

        CONFIGURATOR.configureReserveAsCollateral(
            SAVAX,
            LTV,
            LIQ_THRESHOLD,
            LIQ_BONUS
        );

        CONFIGURATOR.setAssetEModeCategory(SAVAX, 2);

        CONFIGURATOR.setReserveFactor(SAVAX, RESERVE_FACTOR);

        CONFIGURATOR.setLiquidationProtocolFee(SAVAX, LIQ_PROTOCOL_FEE);

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

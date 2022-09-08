// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';

/**
 * @dev This steward enables BTCB as collateral on AAVE V3 Avalanche
 * - Parameter snapshot: https://snapshot.org/#/aave.eth/proposal/0xa947772b3880e77a14ffc22cb30cde36332fd2f779b3f345608d96e4c6e203c2
 * Opposed to the suggested parameters this proposal will
 * - add a supply cap of 1k BTC.b (45% of circulating supply)
 */
contract AaveV3AvaBTCBListingSteward is StewardBase {
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

    address public constant BTCB = 0x152b9d0FdC40C096757F570A51E494bd4b943E50;
    string public constant BTCB_NAME = 'Aave Avalanche BTC.b';
    string public constant ABTCB_SYMBOL = 'aAvaBTC.b';
    string public constant VDBTCB_NAME = 'Aave Avalanche Variable Debt BTC.b';
    string public constant VDBTCB_SYMBOL = 'variableDebtAvaBTC.b';
    string public constant SDBTCB_NAME = 'Aave Avalanche Stable Debt BTC.b';
    string public constant SDBTCB_SYMBOL = 'stableDebtAvaBTC.b';

    address public constant PRICE_FEED_BTCB =
        0x2779D32d5166BAaa2B2b658333bA7e6Ec0C65743;

    address public constant ATOKEN_IMPL =
        0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B;
    address public constant VDTOKEN_IMPL =
        0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3;
    address public constant SDTOKEN_IMPL =
        0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e;
    address public constant RATE_STRATEGY =
        0x79a906e8c998d2fb5C5D66d23c4c5416Fe0168D6;

    uint256 public constant LTV = 7000; // 70%
    uint256 public constant LIQ_THRESHOLD = 7500; // 75%
    uint256 public constant LIQ_BONUS = 10650; // 6.5%

    uint256 public constant RESERVE_FACTOR = 2000; // 20%

    uint256 public constant SUPPLY_CAP = 2_900;
    uint256 public constant BORROW_CAP = 1_450; // 50%
    uint256 public constant LIQ_PROTOCOL_FEE = 1000; // 10%

    function listAssetAddingOracle()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        // ----------------------------
        // 1. New price feed on oracle
        // ----------------------------

        require(PRICE_FEED_BTCB != address(0), 'INVALID_PRICE_FEED');

        address[] memory assets = new address[](1);
        assets[0] = BTCB;
        address[] memory sources = new address[](1);
        sources[0] = PRICE_FEED_BTCB;

        AaveV3Avalanche.ORACLE.setAssetSources(assets, sources);

        // ------------------------------------------------Any
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
            underlyingAssetDecimals: IERC20(BTCB).decimals(),
            interestRateStrategyAddress: RATE_STRATEGY,
            underlyingAsset: BTCB,
            treasury: AAVE_TREASURY,
            incentivesController: INCENTIVES_CONTROLLER,
            aTokenName: BTCB_NAME,
            aTokenSymbol: ABTCB_SYMBOL,
            variableDebtTokenName: VDBTCB_NAME,
            variableDebtTokenSymbol: VDBTCB_SYMBOL,
            stableDebtTokenName: SDBTCB_NAME,
            stableDebtTokenSymbol: SDBTCB_SYMBOL,
            params: bytes('')
        });

        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        configurator.initReserves(initReserveInputs);

        configurator.setSupplyCap(BTCB, SUPPLY_CAP);
        
        configurator.setBorrowCap(BTCB, BORROW_CAP);

        configurator.setReserveBorrowing(BTCB, true);

        configurator.configureReserveAsCollateral(
            BTCB,
            LTV,
            LIQ_THRESHOLD,
            LIQ_BONUS
        );

        configurator.setReserveFactor(BTCB, RESERVE_FACTOR);

        configurator.setLiquidationProtocolFee(BTCB, LIQ_PROTOCOL_FEE);
    }
}

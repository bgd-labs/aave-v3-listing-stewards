// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {AaveV3PolygonMockListing} from '../contracts/v3-ethereum/AaveV3PolygonMockListing.sol';
import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {GenericV3ListingEngine} from '../contracts/common/GenericV3ListingEngine.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens} from './helpers/AaveV3Helpers.sol';

contract GenericV3ListingEngineTest is Test {
    using stdStorage for StdStorage;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('polygon'), 36329200);
    }

    function testEngine() public {
        GenericV3ListingEngine listingEngine = new GenericV3ListingEngine(
            AaveV3Polygon.POOL_CONFIGURATOR,
            AaveV3Polygon.ORACLE,
            AaveV3Polygon.DEFAULT_A_TOKEN_IMPL_REV_1,
            AaveV3Polygon.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
            AaveV3Polygon.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
            AaveV3Polygon.DEFAULT_INCENTIVES_CONTROLLER,
            AaveV3Polygon.COLLECTOR
        );
        AaveV3PolygonMockListing payload = new AaveV3PolygonMockListing(
            listingEngine
        );

        vm.startPrank(AaveV3Polygon.ACL_ADMIN);
        AaveV3Polygon.ACL_MANAGER.addPoolAdmin(address(payload));
        vm.stopPrank();

        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        payload.execute();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: '1INCH',
            underlying: 0x9c2C5fd7b07E95EE044DDeba0E97a665F142394f,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 82_50,
            liquidationThreshold: 86_00,
            liquidationBonus: 105_00,
            liquidationProtocolFee: 10_00,
            reserveFactor: 10_00,
            usageAsCollateralEnabled: true,
            borrowingEnabled: true,
            interestRateStrategy: AaveV3Helpers
                ._findReserveConfig(allConfigsAfter, 'WBTC', false)
                .interestRateStrategy,
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            isSiloed: false,
            isBorrowableInIsolation: false,
            supplyCap: 85_000,
            borrowCap: 60_000,
            debtCeiling: 0,
            eModeCategory: 0
        });

        AaveV3Helpers._validateReserveConfig(
            expectedAssetConfig,
            allConfigsAfter
        );

        AaveV3Helpers._noReservesConfigsChangesApartNewListings(
            allConfigsBefore,
            allConfigsAfter
        );

        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, '1INCH', false),
            ReserveTokens({
                aToken: listingEngine.ATOKEN_IMPL(),
                stableDebtToken: listingEngine.STOKEN_IMPL(),
                variableDebtToken: listingEngine.VTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(
            0x9c2C5fd7b07E95EE044DDeba0E97a665F142394f,
            0x443C5116CdF663Eb387e72C688D276e702135C87
        );

        // impl should be same as e.g. USDC
        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'WBTC', false),
            ReserveTokens({
                aToken: listingEngine.ATOKEN_IMPL(),
                stableDebtToken: listingEngine.STOKEN_IMPL(),
                variableDebtToken: listingEngine.VTOKEN_IMPL()
            })
        );
    }
}

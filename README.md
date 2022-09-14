# Aave V3. Assets Stewards

Helper smart contracts to list assets on Aave v3 or change configs. Designed to be used mainly by Guardians

<br>

| Asset | Type | Pool              | Steward                                                              | Tests                                                      |
| ----- | ----------------- | ----------------- | -------------------------------------------------------------------- | ---------------------------------------------------------- |
| sAVAX | asset-listing | Aave v3 Avalanche | [sAVAX Steward](./src/contracts/savax/AaveV3SAVAXListingSteward.sol) | [Tests](./src/test/sAVAXAaveV3AvaListingByGuardian.t.sol) |
| FRAX | asset-listing | Aave v3 Avalanche | [FRAX Steward](./src/contracts/frax/AaveV3AvaFRAXListingSteward.sol) | [Tests](./src/test/FRAXAaveV3AvaListingByGuardian.t.sol) |
| FRAX | asset-listing | Aave v3 Fantom | [FRAX Steward](./src/contracts/frax/AaveV3FantomFRAXListingSteward.sol) | [Tests](./src/test/FRAXAaveV3FantomListingByGuardian.t.sol) |
| sUSD | config-change | Aave v3 Optimism | [sUSD enable collateral Steward](./src/contracts/susd/AaveV3OptimismEnableCollateralSteward.sol) | [Tests](./src/test/sUSDAaveV3OptimismEnableAsCollateralByGuardian.t.sol) |
| MAI | asset-listing | Aave v3 Avalanche | [MAI Steward](./src/contracts/mimatic/AaveV3AvaMAIListingSteward.sol) | [Tests](./src/test/MAIAaveV3AvaListingByGuardian.t.sol) |
| MIMATIC (MAI) | asset-listing | Aave v3 Fantom | [MIMATIC Steward](./src/contracts/mimatic/AaveV3FantomMIMATICListingSteward.sol) | [Tests](./src/test/MIMATICAaveV3FantomListingByGuardian.t.sol) |
| Multiple | config-change | Aave v3 Harmony | [Harmony freezing](./src/contracts/harmony-protection/FreezeHarmonyPoolReservesSteward.sol) | [Tests](./src/test/FreezeAllReservesAaveV3FantomByGuardian.t.sol) |
| Multiple | config-change | Aave v3 Fantom | [Fantom freezing](./src/contracts/fantom-freeze/FreezeFantomPoolReservesSteward.sol) | [Tests](./src/test/FreezeAllReservesAaveV3HarmonyByGuardian.t.sol) |

<br>

### Copyright

2022 BGD Labs

# Aave V3. Assets Stewards

Helper smart contracts to list assets on Aave v3 or change configs. Designed to be used mainly by Guardians

<br>

| Asset | Type | Pool              | Steward                                                              | Tests                                                      |
| ----- | ----------------- | ----------------- | -------------------------------------------------------------------- | ---------------------------------------------------------- |
| sAVAX | asset-listing | Aave v3 Avalanche | [sAVAX Steward](./src/contracts/savax/AaveV3SAVAXListingSteward.sol) | [Tests](./src/test/sAVAXAaveV3AvaListingByGuardian.t.sol) |
| FRAX | asset-listing | Aave v3 Avalanche | [FRAX Steward](./src/contracts/frax/AaveV3AvaFRAXListingSteward.sol) | [Tests](./src/test/FRAXAaveV3AvaListingByGuardian.t.sol) |
| FRAX | asset-listing | Aave v3 Fantom | [FRAX Steward](./src/contracts/frax/AaveV3FantomFRAXListingSteward.sol) | [Tests](./src/test/FRAXAaveV3FantomListingByGuardian.t.sol) |
| sUSD | config-change | Aave v3 Optimism | [sUSD enable collateral Steward](./src/contracts/susd/AaveV3OptimismEnableCollateralSteward.sol) | [Tests](./src/test/sUSDAaveV3OptimismEnableAsCollateralByGuardian.t.sol) |

<br>

### Copyright

2022 BGD Labs

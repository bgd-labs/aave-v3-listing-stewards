# Aave V3. Assets Stewards

Helper smart contracts to list assets on Aave v3 or change configs. Designed to be used mainly by Guardians

| Asset         | Type          | Pool              | Steward                                                                                          | Tests                                                                    | Address                                                                                                                    |
| ------------- | ------------- | ----------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| sAVAX         | asset-listing | Aave v3 Avalanche | [sAVAX Steward](./src/contracts/savax/AaveV3SAVAXListingSteward.sol)                             | [Tests](./src/test/sAVAXAaveV3AvaListingByGuardian.t.sol)                | [0x1E12071BD95341aA92FcBA1513C714F9F49282A4](https://snowtrace.io/address/0x1E12071BD95341aA92FcBA1513C714F9F49282A4#code)                                                                                                                        |
| FRAX          | asset-listing | Aave v3 Avalanche | [FRAX Steward](./src/contracts/frax/AaveV3AvaFRAXListingSteward.sol)                             | [Tests](./src/test/FRAXAaveV3AvaListingByGuardian.t.sol)                 | [0x1BFC7cc57b851c8Ea3526c0c7573A697de220b77](https://snowtrace.io/address/0x1BFC7cc57b851c8Ea3526c0c7573A697de220b77#code)                                                                                                                        |
| FRAX          | asset-listing | Aave v3 Fantom    | [FRAX Steward](./src/contracts/frax/AaveV3FantomFRAXListingSteward.sol)                          | [Tests](./src/test/FRAXAaveV3FantomListingByGuardian.t.sol)              | N/A                                                                                                                        |
| sUSD          | config-change | Aave v3 Optimism  | [sUSD enable collateral Steward](./src/contracts/susd/AaveV3OptimismEnableCollateralSteward.sol) | [Tests](./src/test/sUSDAaveV3OptimismEnableAsCollateralByGuardian.t.sol) | [0x038b1DEd4911BB6824934cF11FC9F15F45b5916b](https://optimistic.etherscan.io/address/0x038b1DEd4911BB6824934cF11FC9F15F45b5916b#code)                                                                                                                        |
| MAI           | asset-listing | Aave v3 Avalanche | [MAI Steward](./src/contracts/mimatic/AaveV3AvaMAIListingSteward.sol)                            | [Tests](./src/test/MAIAaveV3AvaListingByGuardian.t.sol)                  | [0xd7A4F572C36d72549817D833E4654D0adbBfFD2F](https://snowtrace.io/address/0xd7A4F572C36d72549817D833E4654D0adbBfFD2F#code)                                                                                                                         |
| MIMATIC (MAI) | asset-listing | Aave v3 Fantom    | [MIMATIC Steward](./src/contracts/mimatic/AaveV3FantomMIMATICListingSteward.sol)                 | [Tests](./src/test/MIMATICAaveV3FantomListingByGuardian.t.sol)           | N/A                                                                                                                       |
| Multiple      | config-change | Aave v3 Harmony   | [Harmony freezing](./src/contracts/harmony-protection/FreezeHarmonyPoolReservesSteward.sol)      | [Tests](./src/test/FreezeAllReservesAaveV3FantomByGuardian.t.sol)        | [0xf202866d9fb6f089587d86d4128e7c8e0fdf94fe](https://explorer.harmony.one/address/0xf202866d9fb6f089587d86d4128e7c8e0fdf94fe)                                                                                                                        |
| Multiple      | config-change | Aave v3 Fantom    | [Fantom freezing](./src/contracts/fantom-freeze/FreezeFantomPoolReservesSteward.sol)             | [Tests](./src/test/FreezeAllReservesAaveV3HarmonyByGuardian.t.sol)       | [0x1aa435ed226014407fa6b889e9d06c02b1a12af3](https://ftmscan.com/address/0x1aa435ed226014407fa6b889e9d06c02b1a12af3#code)                                                                                                                        |
| BTC.b         | asset-listing | Aave v3 Avalanche | [BTC.b Steward](./src/contracts/btc.b/AaveV3AvaBTCBListingSteward.sol)                           | [Tests](./src/test/BTCBAaveV3AvaListingByGuardian.t.sol)                 | [0xeee4877a56392c82578df71e8b9270ad8cbabfdc](https://snowtrace.io/address/0xeee4877a56392c82578df71e8b9270ad8cbabfdc#code) |
| Multiple      | config-change | Aave v3 Avalanche    | [Supply Caps Steward](./src/contracts/v3-ava-supply-caps-30-11-2022/AaveV3AvaCapsSteward.sol)             | [Tests](./src/test/AaveV3AvaCaps30-11-2022-ByGuardian.t.sol)       | N/A                                                                                                                      |
| Multiple      | config-change | Aave v3 Avalanche    | [Borrow Caps Steward](./src/contracts/v3-ava-borrow-caps-06-12-2022/AaveV3AvaBorrowCapsSteward.sol)             | [Tests](./src/test/AaveV3AvaBorrowCaps06-12-2022-ByGuardian.t.sol)       | N/A                                                                                                                      |


### Copyright

2022 BGD Labs

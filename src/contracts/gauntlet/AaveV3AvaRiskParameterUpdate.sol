// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

uint256 constant NUM_UPDATES = 5;

struct Updates {
    ParameterSet[NUM_UPDATES] parameters;
}

struct ParameterSet {
    string symbol;
    address _address;
    uint32 ltv;
    uint32 liquidationThreshold;
    uint32 liquidationBonus;
}

/**
 * @dev This steward sets risk parameters for collateral assets on Aave V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xa95e81de4734e676409ec16f5ea8206279e8eb2fab3f4fb3fca779f54d78f7fd
 * - Dicussion: https://governance.aave.com/t/arc-risk-parameter-updates-for-aave-v3-avalanche-2022-10-15/10280/
 */
contract AaveV3AvaRiskParameterUpdate is StewardBase {
    function _getUpdates() external pure returns (
        Updates memory
    ) {
        Updates memory updates = Updates({
            parameters: [
                ParameterSet({
                    symbol: 'AAVE.e',
                    _address: 0x63a72806098Bd3D9520cC43356dD78afe5D386D9,
                    ltv: 6000,
                    liquidationThreshold: 7130,
                    liquidationBonus: 10750
                }),
                ParameterSet({
                    symbol: 'DAI.e',
                    _address: 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70,
                    ltv: 7500,
                    liquidationThreshold: 8200,
                    liquidationBonus: 10500
                }),
                ParameterSet({
                    symbol: 'USDC',
                    _address: 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E,
                    ltv: 8250,
                    liquidationThreshold: 8625,
                    liquidationBonus: 10400
                }),
                ParameterSet({
                    symbol: 'USDt',
                    _address: 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7,
                    ltv: 7500,
                    liquidationThreshold: 8100,
                    liquidationBonus: 10500
                }),
                ParameterSet({
                    symbol: 'WBTC.e',
                    _address: 0x50b7545627a5162F82A992c33b87aDc75187B218,
                    ltv: 7000,
                    liquidationThreshold: 7500,
                    liquidationBonus: 10625
                })
            ]
        });

        return updates;
    }

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        Updates memory updates = this._getUpdates();

        for (uint256 i = 0; i < updates.parameters.length; i++) {
            ParameterSet memory parameterSet = updates.parameters[i];

            configurator.configureReserveAsCollateral(
                parameterSet._address,
                parameterSet.ltv,
                parameterSet.liquidationThreshold,
                parameterSet.liquidationBonus
            );
        }
    }
}

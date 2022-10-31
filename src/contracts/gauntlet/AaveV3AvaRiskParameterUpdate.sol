// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

uint256 constant NUM_UPDATES = 1;

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
 * - Snapshot:
 * - Dicussion:
 */
contract AaveV3AvaRiskParameterUpdate is StewardBase {
    function _getUpdates() external pure returns (
        Updates memory
    ) {
        // Random test recommendations for now
        Updates memory updates = Updates({
            parameters: [
                ParameterSet({
                    symbol: 'USDC',
                    _address: 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E,
                    ltv: 8000,
                    liquidationThreshold: 8625,
                    liquidationBonus: 10500
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

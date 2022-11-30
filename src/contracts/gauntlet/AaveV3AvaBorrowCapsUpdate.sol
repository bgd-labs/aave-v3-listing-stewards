// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

uint256 constant NUM_UPDATES = 3;

struct ParameterSet {
    string symbol;
    address _address;
    uint256 borrowCap;
}

/**
 * @dev This steward sets borrow caps for collateral assets on Aave V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0x3f4a96dcf93b2d9c7cbfa6c1b627f995ed420e57492b333843783434588f4370
 * - Dicussion: https://governance.aave.com/t/arc-risk-parameter-updates-for-aave-v2-polygon-and-aave-v3-avax-2022-11-23/10793
 */
contract AaveV3AvaBorrowCapsUpdate is StewardBase {
    function _getUpdates() external pure returns (
        ParameterSet[NUM_UPDATES] memory
    ) {
        ParameterSet[NUM_UPDATES] memory parameters = [
            ParameterSet({
                symbol: 'FRAX',
                _address: 0xD24C2Ad096400B6FBcd2ad8B24E7acBc21A1da64,
                borrowCap: 2000000
            }),
            ParameterSet({
                symbol: 'MAI',
                _address: 0x5c49b268c9841AFF1Cc3B0a418ff5c3442eE3F3b,
                borrowCap: 2000000
            }),
            ParameterSet({
                symbol: 'LINK.e',
                _address: 0x5947BB275c521040051D82396192181b413227A3,
                borrowCap: 220000
            })
        ];

        return parameters;
    }

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        ParameterSet[NUM_UPDATES] memory parameters = this._getUpdates();

        for (uint256 i = 0; i < parameters.length; i++) {
            ParameterSet memory parameterSet = parameters[i];
            configurator.setBorrowCap(
                parameterSet._address,
                parameterSet.borrowCap
            );
        }
    }
}

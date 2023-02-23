// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward sets supply caps for sAVAX asset on AAVE V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xc4fc70d893c53a28df55fd66264458f1c693770201b4f83cf784bb66ee83044a
 * - Dicussion: https://governance.aave.com/t/arc-supply-cap-update-savax-avalanche-v3/11904
 */
contract AaveV3AvaSAVAXCapsSteward is StewardBase {
    address public constant SAVAX = AaveV3AvalancheAssets.sAVAX_UNDERLYING;

    uint256 public constant SAVAX_CAP = 2_000_000;

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        //2M sAVAX CAP
        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(SAVAX, SAVAX_CAP);

    }
}

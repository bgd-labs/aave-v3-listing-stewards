// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../common/StewardBase.sol';
import {AaveV3Harmony} from 'aave-address-book/AaveAddressBook.sol';

/**
 * @dev One-time-use helper contract to be used by Aave Guardians (Gnosis Safe generally).
 * @dev This Steward freezes all reserves of Aave V3 Harmony, only allowing repayment, withdrawal and liquidation.
 * - The action is approved by the Guardian by just sending the necessary permissions to this contract.
 * - The permissions needed in this case are: risk admin.
 * - The contracts renounces to the permissions after the action.
 * - The contract "burns" the ownership after the action.
 * - Approval on Snapshot: https://snapshot.org/#/aave.eth/proposal/0x81a78109941e5e0ac6cb5ebf82597c839c20ad6821a8c3ff063dba39032533d4
 */
contract FreezeHarmonyPoolReservesSteward is StewardBase {
    function freezeAllReserves()
        external
        withRennounceOfAllAavePermissions(AaveV3Harmony.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        address[] memory reserves = ALL_RESERVES();

        for (uint256 i = 0; i < reserves.length; i++) {
            AaveV3Harmony.POOL_CONFIGURATOR.setReserveFreeze(reserves[i], true);
        }
    }

    function ALL_RESERVES() public pure returns (address[] memory) {
        address[] memory reserves = new address[](8);
        reserves[0] = 0xEf977d2f931C1978Db5F6747666fa1eACB0d0339; // 1DAI
        reserves[1] = 0x985458E523dB3d53125813eD68c274899e9DfAb4; // 1USDC
        reserves[2] = 0x3C2B8Be99c50593081EAA2A724F0B8285F5aba8f; // 1USDT
        reserves[3] = 0xcF323Aad9E522B93F11c352CaA519Ad0E14eB40F; // 1AAVE
        reserves[4] = 0x6983D1E6DEf3690C4d616b13597A09e6193EA013; // 1ETH
        reserves[5] = 0x218532a12a389a4a92fC0C5Fb22901D1c19198aA; // LINK
        reserves[6] = 0x3095c7557bCb296ccc6e363DE01b760bA031F2d9; // 1WBTC
        reserves[7] = 0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a; // WONE

        return reserves;
    }
}

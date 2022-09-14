// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../common/StewardBase.sol';
import {AaveV3Fantom} from 'aave-address-book/AaveAddressBook.sol';

/**
 * @dev One-time-use helper contract to be used by Aave Guardians (Gnosis Safe generally).
 * @dev This Steward freezes all reserves of Aave V3 Fantom, only allowing repayment, withdrawal and liquidation.
 * - The action is approved by the Guardian by just sending the necessary permissions to this contract.
 * - The permissions needed in this case are: risk admin.
 * - The contracts renounces to the permissions after the action.
 * - The contract "burns" the ownership after the action.
 * - Approval on Snapshot: https://snapshot.org/#/aave.eth/proposal/0xeefcd76e523391a14cfd0a79b531ea0a3faf0eb4a058e255fac13a2d224cc647
 */
contract FreezeFantomPoolReservesSteward is StewardBase {
    function freezeAllReserves()
        external
        withRennounceOfAllAavePermissions(AaveV3Fantom.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        address[] memory reserves = AaveV3Fantom.POOL.getReservesList();

        for (uint256 i = 0; i < reserves.length; i++) {
            AaveV3Fantom.POOL_CONFIGURATOR.setReserveFreeze(reserves[i], true);
        }
    }
}

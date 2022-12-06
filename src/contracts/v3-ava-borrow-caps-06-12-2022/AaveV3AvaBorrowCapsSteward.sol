// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This payload sets borrow caps for multiple assets on AAVE V3 Avalanche
 * - Snapshot: TBD //TODO
 * - Dicussion: https://governance.aave.com/t/arc-v3-borrow-cap-recommendations-fast-track-01-05-2022/10927
 */
contract AaveV3AvaBorrowCapsSteward is StewardBase {
    address public constant WETHe = 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB;
    address public constant BTCb = 0x152b9d0FdC40C096757F570A51E494bd4b943E50;
    address public constant LINKe = 0x5947BB275c521040051D82396192181b413227A3;

    uint256 public constant WETHe_CAP = 62_150;
    uint256 public constant BTCb_CAP = 3_190;
    uint256 public constant LINKe_CAP = 207_081;

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;

        configurator.setBorrowCap(WETHe, WETHe_CAP);

        configurator.setBorrowCap(BTCb, BTCb_CAP);

        configurator.setBorrowCap(LINKe, LINKe_CAP);
    }
}

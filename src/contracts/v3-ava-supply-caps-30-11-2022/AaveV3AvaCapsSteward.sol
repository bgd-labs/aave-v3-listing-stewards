// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../common/StewardBase.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward sets supply caps for multiple assets on AAVE V3 Avalanche
 * - Snapshot: https://snapshot.org/#/aave.eth/proposal/0xf40a7b4a6ecd5325553593f0f9fdc8ba04808573fdf76fc277aee52b5396a588
 * - Dicussion: https://governance.aave.com/t/arc-v3-supply-cap-recommendations-for-uncapped-assets-fast-track/10750/6
 */
contract AaveV3AvaCapsSteward is StewardBase {
    address public constant WETHe = 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB;
    address public constant WBTCe = 0x50b7545627a5162F82A992c33b87aDc75187B218;
    address public constant LINKe = 0x5947BB275c521040051D82396192181b413227A3;
    address public constant AAVEe = 0x63a72806098Bd3D9520cC43356dD78afe5D386D9;
    address public constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;

    uint256 public constant WETHe_CAP = 113_000;
    uint256 public constant WBTCe_CAP = 5_233;
    uint256 public constant LINKe_CAP = 353_000;
    uint256 public constant AAVEe_CAP = 4_500;
    uint256 public constant WAVAX_CAP = 131_000_000;

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {
        IPoolConfigurator configurator = AaveV3Avalanche.POOL_CONFIGURATOR;
        //113K ETH CAP
        configurator.setSupplyCap(WETHe, WETHe_CAP);

        //5233 BTC BTC CAP
        configurator.setSupplyCap(WBTCe, WBTCe_CAP);

        //353K LINK CAP
        configurator.setSupplyCap(LINKe, LINKe_CAP);

        //4.5K AAVE CAP
        configurator.setSupplyCap(AAVEe, AAVEe_CAP);

        //13.1M WAVAX CAP
        configurator.setSupplyCap(WAVAX, WAVAX_CAP);
    }
}

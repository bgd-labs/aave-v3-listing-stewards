// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import '../common/StewardBase.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @dev This steward sets caps for multi-assets on avalanche
 * - Dicussion: https://governance.aave.com/t/arc-chaos-labs-supply-and-borrow-cap-updates-aave-v3-2023-02-24/12048
 */
contract AaveV3AvaCapsSteward is StewardBase {
    
    address public constant DAIe = AaveV3AvalancheAssets.DAIe_UNDERLYING;
    address public constant FRAX = AaveV3AvalancheAssets.FRAX_UNDERLYING;
    address public constant MAI = AaveV3AvalancheAssets.MAI_UNDERLYING;
    address public constant USDC = AaveV3AvalancheAssets.USDC_UNDERLYING;
    address public constant USDT = AaveV3AvalancheAssets.USDt_UNDERLYING;
    address public constant AAVEe = AaveV3AvalancheAssets.AAVEe_UNDERLYING;
    address public constant LINKe = AaveV3AvalancheAssets.LINKe_UNDERLYING;
    address public constant BTCB = AaveV3AvalancheAssets.BTCb_UNDERLYING;
    address public constant WBTC = AaveV3AvalancheAssets.WBTCe_UNDERLYING;
    address public constant WETH = AaveV3AvalancheAssets.WETHe_UNDERLYING;
    address public constant WAVAX = AaveV3AvalancheAssets.WAVAX_UNDERLYING;

        string public constant DAISymbol = 'DAI.e';
    uint256 public constant DAI_SUPPLY_CAP = 30_000_000;
    uint256 public constant DAI_BORROW_CAP = 20_000_000;

    string public constant FRAXSymbol = 'FRAX';
    uint256 public constant FRAX_SUPPLY_CAP = 1_500_000;
    uint256 public constant FRAX_BORROW_CAP = 1_000_000;

    string public constant MAISymbol = 'MAI';
    uint256 public constant MAI_SUPPLY_CAP = 700_000;
    uint256 public constant MAI_BORROW_CAP = 460_000;

    string public constant USDCSymbol = 'USDC';
    uint256 public constant USDC_SUPPLY_CAP = 250_000_000;
    uint256 public constant USDC_BORROW_CAP = 175_000_000;

    string public constant USDTSymbol = 'USDt';
    uint256 public constant USDT_SUPPLY_CAP = 200_000_000;
    uint256 public constant USDT_BORROW_CAP = 140_000_000;

    string public constant AAVEeSymbol = 'AAVE.e';
    uint256 public constant AAVEe_SUPPLY_CAP = 5_800;

    string public constant LINKSymbol = 'LINK.e';
    uint256 public constant LINKe_SUPPLY_CAP = 440_000;

    string public constant BTCBSymbol = 'BTC.b';
    uint256 public constant BTCB_SUPPLY_CAP = 3_500;
    uint256 public constant BTCB_BORROW_CAP = 1_900;
    
    string public constant WBTCSymbol = 'WBTC.e';
    uint256 public constant WBTC_SUPPLY_CAP = 2_000;
    uint256 public constant WBTC_BORROW_CAP = 1_100;

    string public constant WETHSymbol = 'WETH.e';
    uint256 public constant WETH_SUPPLY_CAP = 38_000;
    uint256 public constant WETH_BORROW_CAP = 20_500;

    string public constant WAVAXSymbol = 'WAVAX';
    uint256 public constant WAVAX_SUPPLY_CAP = 3_800_000;
    uint256 public constant WAVAX_BORROW_CAP = 1_200_000;

    function execute()
        external
        withRennounceOfAllAavePermissions(AaveV3Avalanche.ACL_MANAGER)
        withOwnershipBurning
        onlyOwner
    {

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(DAIe, DAI_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(DAIe, DAI_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(FRAX, FRAX_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(FRAX, FRAX_BORROW_CAP);
                
        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(MAI, MAI_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(MAI, MAI_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(USDC, USDC_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(USDC, USDC_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(USDT, USDT_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(USDT, USDT_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(AAVEe, AAVEe_SUPPLY_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(LINKe, LINKe_SUPPLY_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(BTCB, BTCB_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(BTCB, BTCB_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(WBTC, WBTC_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(WBTC, WBTC_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(WETH, WETH_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(WETH, WETH_BORROW_CAP);

        AaveV3Avalanche.POOL_CONFIGURATOR.setSupplyCap(WAVAX, WAVAX_SUPPLY_CAP);
        AaveV3Avalanche.POOL_CONFIGURATOR.setBorrowCap(WAVAX, WAVAX_BORROW_CAP);
    }
}

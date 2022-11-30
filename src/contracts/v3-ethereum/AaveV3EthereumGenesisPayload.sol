// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {GenericV3ListingEngine} from '../common/GenericV3ListingEngine.sol';
import {AaveV2Ethereum} from 'aave-address-book/AaveV2Ethereum.sol';

/**
 * @dev Payload smart contract for the Aave governance to:
 *   - Activate the Aave v3 Ethereum pool (un-pausing it)
 *   - List the initial assets, suggested by risk providers and pre-approved by the community
 * Snapshot: https://snapshot.org/#/aave.eth/proposal/0x288caef0d79e5883884324b90daa3c5550135ea0c78738e7ca2363243340c2da
 * Discussion: https://governance.aave.com/t/arc-aave-v3-ethereum-deployment-assets-and-configurations/10238
 * @author BGD Labs
 */
contract AaveV3EthereumGenesisPayload is GenericV3ListingEngine {
    constructor()
        GenericV3ListingEngine(
            address(0), // TODO
            address(0), // TODO
            address(0), // TODO
            address(0), // TODO
            address(0), // TODO
            address(0), // TODO
            AaveV2Ethereum.COLLECTOR
        )
    {}

    function getAllConfigs() public override returns (Listing[] memory) {
        Listing[] memory listings = new Listing[](2);

        listings[0] = Listing({
            asset: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            assetSymbol: 'WETH',
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            rateStrategy: address(0), // TODO
            enabledToBorrow: true,
            stableRateModeEnabled: false, // TODO
            borrowableInIsolation: false,
            LTV: 82_50,
            liqThreshold: 86_00,
            liqBonus: 5_00,
            reserveFactor: 10_00,
            supplyCap: 85_000,
            borrowCap: 60_000,
            debtCeiling: 0,
            liqProtocolFee: 10_00
        });
        listings[1] = Listing({
            asset: address(0), // TODO
            assetSymbol: 'USDC',
            priceFeed: address(0), // TODO
            rateStrategy: address(0), // TODO
            enabledToBorrow: true,
            stableRateModeEnabled: false, // TODO
            borrowableInIsolation: false, // TODO
            LTV: 0, // TODO
            liqThreshold: 0, // TODO
            liqBonus: 0, // TODO
            reserveFactor: 0, // TODO
            supplyCap: 0, // TODO
            borrowCap: 0, // TODO
            debtCeiling: 0,
            liqProtocolFee: 0 // TODO
        });

        return listings;
    }

    function execute() external {
        POOL_CONFIGURATOR.setPoolPause(false);

        super._listAssets();
    }
}

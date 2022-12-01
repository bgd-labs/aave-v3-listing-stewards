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
            0xB305369CC06FD05898b1DCFb96Ae27D0c783a89e, // TODO currently fork
            0xc1EeD9232A0A44c2463ACB83698c162966FBc78d, // TODO currently fork
            0x6484EB0792c646A4827638Fc1B6F20461418eB00, // TODO currently fork
            0x04f1A5b9BD82a5020C49975ceAd160E98d8B77Af, // TODO currently fork
            0x840748F7Fd3EA956E5f4c88001da5CC1ABCBc038, // TODO currently fork
            0xE4FAEc0F9344dF83E71C4E0043e058304ACbcC09, // TODO currently fork
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
            asset: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // TODO
            assetSymbol: 'USDC',
            priceFeed: 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6,
            rateStrategy: address(0), // TODO
            enabledToBorrow: true,
            stableRateModeEnabled: false, // TODO
            borrowableInIsolation: true, // TODO
            LTV: 80_00, // TODO
            liqThreshold: 82_00, // TODO
            liqBonus: 4_50, // TODO
            reserveFactor: 10_00, // TODO
            supplyCap: 100_000_000, // TODO
            borrowCap: 75_000_000, // TODO
            debtCeiling: 0,
            liqProtocolFee: 10_00 // TODO
        });

        return listings;
    }

    function execute() external {
        POOL_CONFIGURATOR.setPoolPause(false);

        super._listAssets();
    }
}

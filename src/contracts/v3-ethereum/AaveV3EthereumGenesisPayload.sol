// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {AaveV3ListingBase} from './AaveV3ListingBase.sol';
import {IGenericV3ListingEngine} from '../common/IGenericV3ListingEngine.sol'; // TODO improve the re-importing
import {AaveV2Ethereum} from 'aave-address-book/AaveV2Ethereum.sol';

/**
 * @dev Payload smart contract for the Aave governance to:
 *   - Activate the Aave v3 Ethereum pool (un-pausing it)
 *   - List the initial assets, suggested by risk providers and pre-approved by the community
 * Snapshot: https://snapshot.org/#/aave.eth/proposal/0x288caef0d79e5883884324b90daa3c5550135ea0c78738e7ca2363243340c2da
 * Discussion: https://governance.aave.com/t/arc-aave-v3-ethereum-deployment-assets-and-configurations/10238
 * @author BGD Labs
 */
contract AaveV3EthereumGenesisPayload is AaveV3ListingBase {
    constructor(IGenericV3ListingEngine listingEngine)
        AaveV3ListingBase(listingEngine)
    {}

    function getAllConfigs()
        public
        override
        returns (IGenericV3ListingEngine.Listing[] memory)
    {
        IGenericV3ListingEngine.Listing[]
            memory listings = new IGenericV3ListingEngine.Listing[](2);

        listings[0] = IGenericV3ListingEngine.Listing({
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
        listings[1] = IGenericV3ListingEngine.Listing({
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

    function getPoolContext()
        public
        override
        returns (IGenericV3ListingEngine.PoolContext memory)
    {
        return
            IGenericV3ListingEngine.PoolContext({
                networkName: 'Ethereum',
                networkAbbreviation: 'Eth'
            });
    }

    function _preExecute() internal override {
        AaveV2Ethereum.POOL_CONFIGURATOR.setPoolPause(false);
    }
}

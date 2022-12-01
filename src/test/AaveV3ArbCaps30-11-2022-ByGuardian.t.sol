// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3OptCapsSteward} from '../contracts/v3-optimism-supply-caps-30-11-2022 /AaveV3OptCapsSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3ArbCapsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470; //TODO - where to get this from?

    string public constant LinkSymbol = 'LINK';
    string public constant WETHSymbol = 'WETH';
    string public constant WBTCSymbol = 'WBTC';
    string public constant AAVESymbol = 'AAVE';

    //20.3K WETH
    uint256 public constant WETH_CAP = 20_300;
    //2.1K WBTC
    uint256 public constant WBTC_CAP = 2_100;
    //350K LINK
    uint256 public constant LINK_CAP = 350_000;
    //2.5K AAVE
    uint256 public constant AAVE_CAP = 2_500;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('arbitrum'), 42713431);
    }

    function testNewSupplyCaps() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3ArbCapsSteward capsSteward = new AaveV3ArbCapsSteward();

        IACLManager aclManager = AaveV3Arbitrum.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(capsSteward));
        aclManager.addRiskAdmin(address(capsSteward));

        capsSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        //LINK
        ReserveConfig memory LinkConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            LinkSymbol,
            false
        );
        LinkConfig.supplyCap = LINKe_CAP;
        AaveV3Helpers._validateReserveConfig(LinkConfig, allConfigsAfter);

        //WETH
        ReserveConfig memory WETHConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WETHSymbol,
            false
        );
        WETHConfig.supplyCap = WETHe_CAP;
        AaveV3Helpers._validateReserveConfig(WETHConfig, allConfigsAfter);

        //WBTC
        ReserveConfig memory WBTCConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WBTCSymbol,
            false
        );
        WBTCConfig.supplyCap = WBTCe_CAP;
        AaveV3Helpers._validateReserveConfig(WBTCConfig, allConfigsAfter);

        //AAVE
        ReserveConfig memory AAVEConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            AAVESymbol,
            false
        );
        AAVEConfig.supplyCap = AAVE_CAP;
        AaveV3Helpers._validateReserveConfig(AAVEConfig, allConfigsAfter);

        require(capsSteward.owner() == address(0), 'INVALID_OWNER_POST_CAPS');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3OptCapsSteward} from '../contracts/v3-optimism-supply-caps-30-11-2022/AaveV3OptCapsSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3OptCapsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470; //TODO - where to get this from?

    string public constant LinkSymbol = 'LINK';
    string public constant WETHSymbol = 'WETH';
    string public constant WBTCSymbol = 'WBTC';

    //35.9K WETH
    uint256 public constant WETH_CAP = 35_900;
    //1.1K WBTC
    uint256 public constant WBTC_CAP = 1_100;
    //258K LINK
    uint256 public constant LINK_CAP = 258_000;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('optimism'), 330680);
    }

    function testNewSupplyCaps() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3OptCapsSteward capsSteward = new AaveV3OptCapsSteward();

        IACLManager aclManager = AaveV3Optimism.ACL_MANAGER;

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
        LinkConfig.supplyCap = LINK_CAP;
        AaveV3Helpers._validateReserveConfig(LinkConfig, allConfigsAfter);

        //WETH
        ReserveConfig memory WETHConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WETHSymbol,
            false
        );
        WETHConfig.supplyCap = WETH_CAP;
        AaveV3Helpers._validateReserveConfig(WETHConfig, allConfigsAfter);

        //WBTC
        ReserveConfig memory WBTCConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WBTCSymbol,
            false
        );
        WBTCConfig.supplyCap = WBTC_CAP;
        AaveV3Helpers._validateReserveConfig(WBTCConfig, allConfigsAfter);

        require(capsSteward.owner() == address(0), 'INVALID_OWNER_POST_CAPS');
    }
}

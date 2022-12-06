// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaBorrowCapsSteward} from '../contracts/v3-ava-borrow-caps-06-12-2022/AaveV3AvaBorrowCapsSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3AvaBorrowCapsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    string public constant WETHSymbol = 'WETH.e';
    string public constant LinkSymbol = 'LINK.e';
    string public constant BTCbSymbol = 'BTC.b';

    uint256 public constant WETHe_CAP = 62_150;
    uint256 public constant BTCb_CAP = 3_190;
    uint256 public constant LINKe_CAP = 207_081;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('avalanche'), 23032057);
    }

    function testNewborrowCaps() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaBorrowCapsSteward capsSteward = new AaveV3AvaBorrowCapsSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(capsSteward));
        aclManager.addRiskAdmin(address(capsSteward));

        capsSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        //WETH
        ReserveConfig memory WETHConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WETHSymbol,
            false
        );
        WETHConfig.borrowCap = WETHe_CAP;
        AaveV3Helpers._validateReserveConfig(WETHConfig, allConfigsAfter);

        //BTCb
        ReserveConfig memory BTCbConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            BTCbSymbol,
            false
        );
        BTCbConfig.borrowCap = BTCb_CAP;
        AaveV3Helpers._validateReserveConfig(BTCbConfig, allConfigsAfter);

        //LINK
        ReserveConfig memory LinkConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            LinkSymbol,
            false
        );
        LinkConfig.borrowCap = LINKe_CAP;
        AaveV3Helpers._validateReserveConfig(LinkConfig, allConfigsAfter);

        require(capsSteward.owner() == address(0), 'INVALID_OWNER_POST_CAPS');
    }
}

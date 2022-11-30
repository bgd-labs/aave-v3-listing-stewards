// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaCapsSteward} from '../contracts/v3-ava-supply-caps-30-11-2022/AaveV3AvaCapsSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3AvaCapsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    string public constant LinkSymbol = 'LINK.e';
    string public constant WETHSymbol = 'WETH.e';
    string public constant AAVESymbol = 'AAVE.e';
    string public constant WAVAXSymbol = 'WAVAX';
    string public constant WBTCSymbol = 'WBTC.e';

    uint256 public constant WETHe_CAP = 113_000;
    uint256 public constant WBTCe_CAP = 5_233;
    uint256 public constant LINKe_CAP = 353_000;
    uint256 public constant AAVEe_CAP = 4_500;
    uint256 public constant WAVAX_CAP = 131_000_000;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('avalanche'), 23032057);
    }

    function testNewSupplyCaps() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaCapsSteward capsSteward = new AaveV3AvaCapsSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

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

        //AAVE
        ReserveConfig memory AAVEConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            AAVESymbol,
            false
        );
        AAVEConfig.supplyCap = AAVEe_CAP;
        AaveV3Helpers._validateReserveConfig(AAVEConfig, allConfigsAfter);

        //WAVAX
        ReserveConfig memory WAVAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WAVAXSymbol,
            false
        );
        WAVAXConfig.supplyCap = WAVAX_CAP;
        AaveV3Helpers._validateReserveConfig(WAVAXConfig, allConfigsAfter);

        //WBTC
        ReserveConfig memory WBTCConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WBTCSymbol,
            false
        );
        WBTCConfig.supplyCap = WBTCe_CAP;
        AaveV3Helpers._validateReserveConfig(WBTCConfig, allConfigsAfter);

        require(capsSteward.owner() == address(0), 'INVALID_OWNER_POST_CAPS');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaCapsSteward} from '../contracts/v3-ava-caps-26-02-2023/v3-ava-caps-26-02-2023.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3AvaChangeCapsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        AaveV3Avalanche.ACL_ADMIN;

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


    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('avalanche'), 26507116); 
    }

    function testNewCaps() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaCapsSteward paramsSteward = new AaveV3AvaCapsSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(paramsSteward));
        aclManager.addRiskAdmin(address(paramsSteward));

        paramsSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        //DAI
        ReserveConfig memory DAIConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            DAISymbol,
            false
        );
        DAIConfig.supplyCap = DAI_SUPPLY_CAP;
        DAIConfig.borrowCap = DAI_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(DAIConfig, allConfigsAfter);

        //FRAX
        ReserveConfig memory FRAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            FRAXSymbol,
            false
        );
        FRAXConfig.supplyCap = FRAX_SUPPLY_CAP;
        FRAXConfig.borrowCap = FRAX_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(FRAXConfig, allConfigsAfter);

        //MAI
        ReserveConfig memory MAIConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            MAISymbol,
            false
        );
        MAIConfig.supplyCap = MAI_SUPPLY_CAP;
        MAIConfig.borrowCap = MAI_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(MAIConfig, allConfigsAfter);

        //USDC
        ReserveConfig memory USDCConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            USDCSymbol,
            false
        );
        USDCConfig.supplyCap = USDC_SUPPLY_CAP;
        USDCConfig.borrowCap = USDC_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(USDCConfig, allConfigsAfter);

        //USDT
        ReserveConfig memory USDTConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            USDTSymbol,
            false
        );
        USDTConfig.supplyCap = USDT_SUPPLY_CAP;
        USDTConfig.borrowCap = USDT_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(USDTConfig, allConfigsAfter);

        //AAVE
        ReserveConfig memory AAVEConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            AAVEeSymbol,
            false
        );
        AAVEConfig.supplyCap = AAVEe_SUPPLY_CAP;
        AaveV3Helpers._validateReserveConfig(AAVEConfig, allConfigsAfter);

        //LINK
        ReserveConfig memory LINKConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            LINKSymbol,
            false
        );
        LINKConfig.supplyCap = LINKe_SUPPLY_CAP;
        AaveV3Helpers._validateReserveConfig(LINKConfig, allConfigsAfter);



        //BTCB
        ReserveConfig memory BTCBConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            BTCBSymbol,
            false
        );
        BTCBConfig.supplyCap = BTCB_SUPPLY_CAP;
        BTCBConfig.borrowCap = BTCB_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(BTCBConfig, allConfigsAfter);

        //WBTC
        ReserveConfig memory WBTCConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WBTCSymbol,
            false
        );
        WBTCConfig.supplyCap = WBTC_SUPPLY_CAP;
        WBTCConfig.borrowCap = WBTC_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(WBTCConfig, allConfigsAfter);

        //WETH
        ReserveConfig memory WETHConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WETHSymbol,
            false
        );
        WETHConfig.supplyCap = WETH_SUPPLY_CAP;
        WETHConfig.borrowCap = WETH_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(WETHConfig, allConfigsAfter);

        //WAVAX
        ReserveConfig memory WAVAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WAVAXSymbol,
            false
        );
        WAVAXConfig.supplyCap = WAVAX_SUPPLY_CAP;
        WAVAXConfig.borrowCap = WAVAX_BORROW_CAP;
        AaveV3Helpers._validateReserveConfig(WAVAXConfig, allConfigsAfter);


        require(paramsSteward.owner() == address(0), 'INVALID_OWNER');
    }
}

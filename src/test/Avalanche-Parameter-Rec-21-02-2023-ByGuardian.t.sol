// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaParamsSteward} from '../contracts/Avalanche-Parameter-Rec-21-02-2023/Avalance-Parameter-Rec-21-02-2023.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3AvaParamsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        AaveV3Avalanche.ACL_ADMIN;

    string public constant LinkSymbol = 'LINK.e';
    string public constant WAVAXSymbol = 'WAVAX';

    uint256 public constant LINKe_LIQ_THRESHOLD	 = 6800;
    uint256 public constant LINKe_LTV = 5300; 
    uint256 public constant LINKe_LIQ_BONUS = 10750; 

    uint256 public constant WAVAX_LIQ_THRESHOLD = 7300; 
    uint256 public constant WAVAX_LTV = 6800; 
    uint256 public constant WAVAX_LIQ_BONUS = 11000; 

    string public constant SAVAXSymbol = 'sAVAX';
    uint256 public constant SAVAX_CAP = 2_000_000;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('avalanche'), 26507116); 
    }

    function testNewParams() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaParamsSteward paramsSteward = new AaveV3AvaParamsSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(paramsSteward));
        aclManager.addRiskAdmin(address(paramsSteward));

        paramsSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        //LINK
        ReserveConfig memory LinkConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            LinkSymbol,
            false
        );

        LinkConfig.ltv = LINKe_LTV;
        LinkConfig.liquidationThreshold = LINKe_LIQ_THRESHOLD;        

        AaveV3Helpers._validateReserveConfig(LinkConfig, allConfigsAfter);

        //WAVAX
        ReserveConfig memory WAVAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WAVAXSymbol,
            false
        );
        WAVAXConfig.ltv = WAVAX_LTV;
        WAVAXConfig.liquidationThreshold = WAVAX_LIQ_THRESHOLD;        

        AaveV3Helpers._validateReserveConfig(WAVAXConfig, allConfigsAfter);


        //sAVAX
        ReserveConfig memory SAVAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            SAVAXSymbol,
            false
        );
        SAVAXConfig.supplyCap = SAVAX_CAP;
        AaveV3Helpers._validateReserveConfig(SAVAXConfig, allConfigsAfter);



        require(paramsSteward.owner() == address(0), 'INVALID_OWNER');
    }
}

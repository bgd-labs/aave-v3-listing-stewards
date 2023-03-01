// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaRiskParamsSteward} from '../contracts/v3-ava-risk-params-20-02-2023/AaveV3AvaRiskParamsSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3AvaRiskParamsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant DEPLOYER =
        0x9A187663E454e99CAFd40a2712606CC306e301b2;

    string public constant WAVAXSymbol = 'WAVAX';

    // previous value: 11000
    uint256 public constant WAVAX_NEW_LIQ_BONUS = 10920;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('avalanche'), 26866114);
    }

    function testNewRiskParams() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(DEPLOYER);

        AaveV3AvaRiskParamsSteward paramsSteward = new AaveV3AvaRiskParamsSteward();

        vm.stopPrank();
        vm.startPrank(GUARDIAN_AVALANCHE);

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addRiskAdmin(address(paramsSteward));

        vm.stopPrank();
        vm.startPrank(DEPLOYER);

        paramsSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        //WAVAX
        ReserveConfig memory WAVAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            WAVAXSymbol,
            false
        );
        WAVAXConfig.liquidationBonus = WAVAX_NEW_LIQ_BONUS;
        AaveV3Helpers._validateReserveConfig(WAVAXConfig, allConfigsAfter);

        require(paramsSteward.owner() == address(0), 'INVALID_OWNER_POST_CAPS');
    }
}

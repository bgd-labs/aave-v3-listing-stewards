// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import 'forge-std/Test.sol';

import {AaveV3Fantom} from 'aave-address-book/AaveAddressBook.sol';
import {FreezeFantomPoolReservesSteward} from '../contracts/fantom-freeze/FreezeFantomPoolReservesSteward.sol';
import 'aave-helpers/ProtocolV3TestBase.sol';

contract FreezeAllReservesAaveV3FantomByGuardian is ProtocolV3TestBase {
    address public constant GUARDIAN =
        0x39CB97b105173b56b5a2b4b33AD25d6a50E6c949;

    function setUp() public {}

    function testFreezingAllReserves() public {
        FreezeFantomPoolReservesSteward freezeSteward = new FreezeFantomPoolReservesSteward();

        vm.startPrank(GUARDIAN);

        AaveV3Fantom.ACL_MANAGER.addRiskAdmin(address(freezeSteward));

        vm.stopPrank();

        this.createConfigurationSnapshot(
            'fantom_pre-freezing',
            AaveV3Fantom.POOL
        );

        freezeSteward.freezeAllReserves();

        this.createConfigurationSnapshot(
            'fantom_post-freezing',
            AaveV3Fantom.POOL
        );

        ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Fantom.POOL);

        for (uint256 i = 0; i < configs.length; i++) {
            require(configs[i].isFrozen, 'AT_LEAST_ONE_RESERVE_NOT_FROZEN');
        }
    }
}

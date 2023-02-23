// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3AvaSAVAXCapsSteward} from '../contracts/v3-ava-supply-caps-savax-23-02-2023/AaveV3AvaSAVAXCapsSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract AaveV3AvaSAVAXCapsByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    string public constant SAVAXSymbol = 'sAVAX';

    uint256 public constant SAVAX_CAP = 2_000_000;


    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('avalanche'), 23032057);
    }

    function testNewSupplyCaps() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_AVALANCHE);

        AaveV3AvaSAVAXCapsSteward capsSteward = new AaveV3AvaSAVAXCapsSteward();

        IACLManager aclManager = AaveV3Avalanche.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(capsSteward));
        aclManager.addRiskAdmin(address(capsSteward));

        capsSteward.execute();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        //LINK
        ReserveConfig memory SAVAXConfig = AaveV3Helpers._findReserveConfig(
            allConfigsBefore,
            SAVAXSymbol,
            false
        );
        SAVAXConfig.supplyCap = SAVAX_CAP;
        AaveV3Helpers._validateReserveConfig(SAVAXConfig, allConfigsAfter);

        require(capsSteward.owner() == address(0), 'INVALID_OWNER_POST_CAPS');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes} from '../../contracts/interfaces/IPoolConfigurator.sol';

contract V3ListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_AVALANCHE =
        0xa35b76E4935449E33C56aB24b23fcd3246f13470;

    address public constant SAVAX = 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE;

    address public constant PRICE_FEED_SAVAX =
        0x2854Ca10a54800e15A2a25cFa52567166434Ff0a;

    address public constant ATOKEN_IMPL =
        0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B;

    address public constant VDTOKEN_IMPL =
        0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3;
    address public constant SDTOKEN_IMPL =
        0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e;

    IPoolConfigurator public constant CONFIGURATOR =
        IPoolConfigurator(0x8145eddDf43f50276641b55bd3AD95944510021E);

    function setUp() public {}

    function testAddSingleDistribution() public {
        vm.startPrank(GUARDIAN_AVALANCHE);

        vm.stopPrank();
    }
}

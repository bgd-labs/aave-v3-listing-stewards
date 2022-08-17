// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Fantom} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3FantomFRAXListingSteward} from '../contracts/frax/AaveV3FantomFRAXListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract FRAXAaveV3FantomListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN =
        0x39CB97b105173b56b5a2b4b33AD25d6a50E6c949;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x39CB97b105173b56b5a2b4b33AD25d6a50E6c949;

    address public constant FRAX = 0xdc301622e621166BD8E82f2cA0A26c13Ad0BE355;

    address public constant FRAX_WHALE =
        0x7a656B342E14F745e2B164890E88017e27AE7320;

    address public constant DAI = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    address public constant DAI_WHALE =
        0xd652776dE7Ad802be5EC7beBfafdA37600222B48;

    address public constant RATE_STRATEGY =
        0xf4a0039F2d4a2EaD5216AbB6Ae4C4C3AA2dB9b82;

    function setUp() public {}

    function testListingFRAX() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN);

        AaveV3FantomFRAXListingSteward listingSteward = new AaveV3FantomFRAXListingSteward();

        IACLManager aclManager = AaveV3Fantom.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(true);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'FRAX',
            underlying: FRAX,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 7500,
            liquidationThreshold: 8000,
            liquidationBonus: 10500,
            liquidationProtocolFee: 1000,
            reserveFactor: 1000,
            usageAsCollateralEnabled: true,
            borrowingEnabled: true,
            interestRateStrategy: AaveV3Helpers
                ._findReserveConfig(allConfigsAfter, 'fUSDT', false)
                .interestRateStrategy,
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            isSiloed: false,
            isBorrowableInIsolation: false,
            supplyCap: 50_000_000,
            borrowCap: 0,
            debtCeiling: 2_000_000_00,
            eModeCategory: 1
        });

        AaveV3Helpers._validateReserveConfig(
            expectedAssetConfig,
            allConfigsAfter
        );

        AaveV3Helpers._noReservesConfigsChangesApartNewListings(
            allConfigsBefore,
            allConfigsAfter
        );

        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'FRAX', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        // impl should be same as USDC
        AaveV3Helpers._validateReserveTokensImpls(
            vm,
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'USDC', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(
            FRAX,
            listingSteward.PRICE_FEED_FRAX()
        );

        _validatePoolActionsPostListing(allConfigsAfter);

        require(
            listingSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        address aFRAX = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'FRAX', false)
            .aToken;
        address vFRAX = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'FRAX', false)
            .variableDebtToken;
        address sFRAX = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'FRAX', false)
            .stableDebtToken;
        address vDAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'DAI', false)
            .variableDebtToken;

        AaveV3Helpers._deposit(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            666 ether,
            true,
            aFRAX
        );

        AaveV3Helpers._borrow(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            DAI,
            222 ether,
            2,
            vDAI
        );

        AaveV3Helpers._borrow(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            200 ether,
            2,
            vFRAX
        );

        // We check proper revert when going over liquidation threshold
        try
            AaveV3Helpers._borrow(
                vm,
                FRAX_WHALE,
                FRAX_WHALE,
                FRAX,
                200 ether,
                2,
                vFRAX
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('36')),
                '_testProposal() : INVALID_VARIABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }

        // We check revert when trying to borrow at stable
        try
            AaveV3Helpers._borrow(
                vm,
                FRAX_WHALE,
                FRAX_WHALE,
                FRAX,
                10 ether,
                1,
                sFRAX
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('31')),
                '_testProposal() : INVALID_VARIABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(FRAX_WHALE, 300 ether);
        vm.stopPrank();

        // Not possible to borrow and repay when vdebt index doesn't changing, so moving 1s
        skip(1);

        AaveV3Helpers._repay(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            DAI,
            IERC20(DAI).balanceOf(FRAX_WHALE),
            2,
            vDAI,
            true
        );

        AaveV3Helpers._repay(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            IERC20(FRAX).balanceOf(FRAX_WHALE),
            2,
            vFRAX,
            true
        );

        AaveV3Helpers._withdraw(
            vm,
            FRAX_WHALE,
            FRAX_WHALE,
            FRAX,
            type(uint256).max,
            aFRAX
        );
    }
}

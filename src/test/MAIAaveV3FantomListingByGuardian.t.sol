// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {IPoolConfigurator, ConfiguratorInputTypes, IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3Fantom} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV3FantomMAIListingSteward} from '../contracts/mai/AaveV3FantomMAIListingSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract MAIAaveV3FantomListingByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN =
        0x39CB97b105173b56b5a2b4b33AD25d6a50E6c949;

    address public constant CURRENT_ACL_SUPERADMIN =
        0x39CB97b105173b56b5a2b4b33AD25d6a50E6c949;

    address public constant MAI = 0xfB98B335551a418cD0737375a2ea0ded62Ea213b;

    address public constant MAI_WHALE = address(0); // There is a lot of burnt tokens

    address public constant DAI = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    address public constant DAI_WHALE =
        0xd652776dE7Ad802be5EC7beBfafdA37600222B48;

    address public constant RATE_STRATEGY =
        0xf4a0039F2d4a2EaD5216AbB6Ae4C4C3AA2dB9b82;

    function setUp() public {}

    function testListing() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN);

        AaveV3FantomMAIListingSteward listingSteward = new AaveV3FantomMAIListingSteward();

        IACLManager aclManager = AaveV3Fantom.ACL_MANAGER;

        aclManager.addAssetListingAdmin(address(listingSteward));
        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.listAssetAddingOracle();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'miMATIC',
            underlying: MAI,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 0,
            liquidationThreshold: 0,
            liquidationBonus: 0,
            liquidationProtocolFee: 1000,
            reserveFactor: 1000,
            usageAsCollateralEnabled: false,
            borrowingEnabled: true,
            interestRateStrategy: AaveV3Helpers
                ._findReserveConfig(allConfigsAfter, 'fUSDT', false)
                .interestRateStrategy,
            stableBorrowRateEnabled: false,
            isActive: true,
            isFrozen: false,
            isSiloed: false,
            supplyCap: 10_000_000,
            borrowCap: 0,
            debtCeiling: 0,
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
            AaveV3Helpers._findReserveConfig(allConfigsAfter, 'miMATIC', false),
            ReserveTokens({
                aToken: listingSteward.ATOKEN_IMPL(),
                stableDebtToken: listingSteward.SDTOKEN_IMPL(),
                variableDebtToken: listingSteward.VDTOKEN_IMPL()
            })
        );

        AaveV3Helpers._validateAssetSourceOnOracle(
            MAI,
            listingSteward.PRICE_FEED()
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

        _validatePoolActionsPostListing(allConfigsAfter);

        require(
            listingSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        address aMAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'miMATIC', false)
            .aToken;
        address vMAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'miMATIC', false)
            .variableDebtToken;
        address sMAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'miMATIC', false)
            .stableDebtToken;
        address aDAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'DAI', false)
            .aToken;
        address vDAI = AaveV3Helpers
            ._findReserveConfig(allReservesConfigs, 'DAI', false)
            .variableDebtToken;

        AaveV3Helpers._deposit(
            vm,
            MAI_WHALE,
            MAI_WHALE,
            MAI,
            666 ether,
            true,
            aMAI
        );

        // We check revert when trying to borrow (not enabled as collateral, so any mode works)
        try
            AaveV3Helpers._borrow(
                vm,
                MAI_WHALE,
                MAI_WHALE,
                MAI,
                10 ether,
                1,
                sMAI
            )
        {
            revert('_testProposal() : BORROW_NOT_REVERTING');
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes('34')),
                '_testProposal() : INVALID_VARIABLE_REVERT_MSG'
            );
            vm.stopPrank();
        }

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(MAI_WHALE, 666 ether);
        vm.stopPrank();

        AaveV3Helpers._deposit(
            vm,
            MAI_WHALE,
            MAI_WHALE,
            DAI,
            666 ether,
            true,
            aDAI
        );

        AaveV3Helpers._borrow(
            vm,
            MAI_WHALE,
            MAI_WHALE,
            MAI,
            222 ether,
            2,
            vMAI
        );

        // Not possible to borrow and repay when vdebt index doesn't changing, so moving 1s
        skip(1);

        AaveV3Helpers._repay(
            vm,
            MAI_WHALE,
            MAI_WHALE,
            MAI,
            IERC20(MAI).balanceOf(MAI_WHALE),
            2,
            vMAI,
            true
        );

        AaveV3Helpers._withdraw(
            vm,
            MAI_WHALE,
            MAI_WHALE,
            MAI,
            type(uint256).max,
            aMAI
        );
    }
}

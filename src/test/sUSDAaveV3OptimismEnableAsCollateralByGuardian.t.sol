// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {AaveV3Optimism} from 'aave-address-book/AaveAddressBook.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {AaveV3OptimismEnableCollateralSteward} from '../contracts/susd/AaveV3OptimismEnableCollateralSteward.sol';
import {AaveV3Helpers, ReserveConfig, ReserveTokens, IERC20} from './helpers/AaveV3Helpers.sol';

contract sUSDAaveV3OptimismEnableAsCollateralByGuardian is Test {
    using stdStorage for StdStorage;

    address public constant GUARDIAN_OPTIMISM =
        0xE50c8C619d05ff98b22Adf991F17602C774F785c;

    address public constant SUSD = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;

    address public constant SUSD_WHALE =
        0xa5f7a39E55D7878bC5bd754eE5d6BD7a7662355b;

    address public constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    address public constant DAI_WHALE =
        0x1337BedC9D22ecbe766dF105c9623922A27963EC;

    address public constant RATE_STRATEGY =
        0xA9F3C3caE095527061e6d270DBE163693e6fda9D;

    function setUp() public {}

    function testSUSDAsCollateral() public {
        ReserveConfig[] memory allConfigsBefore = AaveV3Helpers
            ._getReservesConfigs(false);

        vm.startPrank(GUARDIAN_OPTIMISM);

        AaveV3OptimismEnableCollateralSteward listingSteward = new AaveV3OptimismEnableCollateralSteward();

        IACLManager aclManager = AaveV3Optimism.ACL_MANAGER;

        aclManager.addRiskAdmin(address(listingSteward));

        listingSteward.updateSUSDConfig();

        vm.stopPrank();

        ReserveConfig[] memory allConfigsAfter = AaveV3Helpers
            ._getReservesConfigs(false);

        ReserveConfig memory expectedAssetConfig = ReserveConfig({
            symbol: 'sUSD',
            underlying: SUSD,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 6000,
            liquidationThreshold: 7500,
            liquidationBonus: 10500,
            liquidationProtocolFee: 1000,
            reserveFactor: 1000,
            usageAsCollateralEnabled: true,
            borrowingEnabled: true,
            interestRateStrategy: RATE_STRATEGY,
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

        AaveV3Helpers._noReservesConfigsChangesApartFrom(
            allConfigsBefore,
            allConfigsAfter,
            'sUSD'
        );

        _validatePoolActionsPostListing(allConfigsAfter);

        require(
            listingSteward.owner() == address(0),
            'INVALID_OWNER_POST_LISTING'
        );

        string[] memory expectedAssetsEmode = new string[](4);
        expectedAssetsEmode[0] = 'DAI';
        expectedAssetsEmode[1] = 'USDC';
        expectedAssetsEmode[2] = 'USDT';
        expectedAssetsEmode[3] = 'sUSD';

        AaveV3Helpers._validateAssetsOnEmodeCategory(
            1,
            allConfigsAfter,
            expectedAssetsEmode
        );
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        AaveV3Helpers._deposit(
            vm,
            SUSD_WHALE,
            SUSD_WHALE,
            SUSD,
            666 ether,
            true,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'sUSD', false)
                .aToken
        );

        AaveV3Helpers._borrow(
            vm,
            SUSD_WHALE,
            SUSD_WHALE,
            DAI,
            222 ether,
            2,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'DAI', false)
                .variableDebtToken
        );

        AaveV3Helpers._borrow(
            vm,
            SUSD_WHALE,
            SUSD_WHALE,
            SUSD,
            5 ether,
            2,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'sUSD', false)
                .variableDebtToken
        );

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(SUSD_WHALE, 300 ether);
        vm.stopPrank();

        // Not possible to borrow and repay when vdebt index doesn't changing, so moving 1s
        skip(1);

        AaveV3Helpers._repay(
            vm,
            SUSD_WHALE,
            SUSD_WHALE,
            DAI,
            IERC20(DAI).balanceOf(SUSD_WHALE),
            2,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'DAI', false)
                .variableDebtToken,
            true
        );

        skip(1);

        AaveV3Helpers._repay(
            vm,
            SUSD_WHALE,
            SUSD_WHALE,
            SUSD,
            IERC20(SUSD).balanceOf(SUSD_WHALE),
            2,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'sUSD', false)
                .variableDebtToken,
            true
        );

        AaveV3Helpers._withdraw(
            vm,
            SUSD_WHALE,
            SUSD_WHALE,
            SUSD,
            type(uint256).max,
            AaveV3Helpers
                ._findReserveConfig(allReservesConfigs, 'sUSD', false)
                .aToken
        );
    }
}

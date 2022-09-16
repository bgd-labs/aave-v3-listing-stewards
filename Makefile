# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes

# IMPORTANT It is highly probable that will be necessary to modify the --fork-block-number, depending on the test
test   :; forge test -vvv --rpc-url=${ETH_RPC_URL} --fork-block-number 16146270
test-susd-collateral :; forge test -vvv --match-contract sUSDAaveV3OptimismEnableAsCollateralByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 14083750
test-frax-ava :; forge test -vvv --match-contract FRAXAaveV3AvaListingByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 17188000
test-frax-fantom :; forge test -vvv --match-contract FRAXAaveV3FantomListingByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 42587570
test-mai-ava :; forge test -vvv --match-contract MAIAaveV3AvaListingByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 17188000
test-mimatic-fantom :; forge test -vvv --match-contract MIMATICAaveV3FantomListingByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 42587570
test-harmony-freezing :; forge test -vvv --match-contract FreezeAllReservesAaveV3HarmonyByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 29264480
test-fantom-freezing :; forge test -vvv --match-contract FreezeAllReservesAaveV3FantomByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 46881340
test-btcb-ava:; forge test -vvv --match-contract BTCBAaveV3AvaListingByGuardian
trace   :; forge test -vvvv --rpc-url=${ETH_RPC_URL} --fork-block-number 16146270
clean  :; forge clean
snapshot :; forge snapshot

# scripts
deploy-ava-frax-steward :;  forge script script/DeployAvaFRAXSteward.s.sol:DeployAvaFRAXSteward --rpc-url ${ETH_RPC_URL} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
verify-ava-frax-steward :;  forge script script/DeployAvaFRAXSteward.s.sol:DeployAvaFRAXSteward --rpc-url ${ETH_RPC_URL} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
deploy-ava-mai-steward :;  forge script script/DeployAvaMAISteward.s.sol:DeployAvaMAISteward --rpc-url ${ETH_RPC_URL} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
verify-ava-mai-steward :;  forge script script/DeployAvaMAISteward.s.sol:DeployAvaMAISteward --rpc-url ${ETH_RPC_URL} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
deploy-fantom-freeze-steward :;  forge script script/DeployFantomFreezeSteward.s.sol:DeployFantomFreezeSteward --rpc-url ${ETH_RPC_URL} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
verify-fantom-freeze-steward :;  forge script script/DeployFantomFreezeSteward.s.sol:DeployFantomFreezeSteward --rpc-url ${ETH_RPC_URL} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
deploy-ava-btcb-steward :;  forge script script/DeployAvaBTCbSteward.s.sol:DeployAvaBTCbSteward --rpc-url ${ETH_RPC_URL} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
verify-ava-btcb-steward :;  forge script script/DeployAvaBTCbSteward.s.sol:DeployAvaBTCbSteward --rpc-url ${ETH_RPC_URL} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

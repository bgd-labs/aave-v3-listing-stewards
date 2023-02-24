# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes

# IMPORTANT It is highly probable that will be necessary to modify the --fork-block-number, depending on the test
test-susd-collateral :; forge test -vvv --match-contract sUSDAaveV3OptimismEnableAsCollateralByGuardian --rpc-url=${RPC_OPTIMISM} --fork-block-number 14083750
test-frax-ava :; forge test -vvv --match-contract FRAXAaveV3AvaListingByGuardian --rpc-url=${RPC_AVALANCHE} --fork-block-number 17188000
test-frax-fantom :; forge test -vvv --match-contract FRAXAaveV3FantomListingByGuardian --rpc-url=${RPC_FANTOM} --fork-block-number 42587570
test-mai-ava :; forge test -vvv --match-contract MAIAaveV3AvaListingByGuardian --rpc-url=${RPC_AVALANCHE} --fork-block-number 17188000
test-mimatic-fantom :; forge test -vvv --match-contract MIMATICAaveV3FantomListingByGuardian --rpc-url=${RPC_FANTOM} --fork-block-number 42587570
test-harmony-freezing :; forge test -vvv --match-contract FreezeAllReservesAaveV3HarmonyByGuardian --rpc-url=${RPC_HARMONY} --fork-block-number 29264480
test-fantom-freezing :; forge test -vvv --match-contract FreezeAllReservesAaveV3FantomByGuardian --rpc-url=${RPC_FANTOM} --fork-block-number 46881340
test-btcb-ava:; forge test -vvv --match-contract BTCBAaveV3AvaListingByGuardian
test-v3-ava-caps:; forge test -vvv --match-contract AaveV3AvaCapsByGuardian
test-v3-ava-params:; forge test -vvv --match-contract AaveV3AvaParamsByGuardian

test-permissions-migration :
	forge test --match-contract PermissionsMigrationToCrosschain -vvv
	make git-diff before=./reports/Optimism_permissions-pre-migration.md after=./reports/Optimism_permissions-post-migration.md out=diff-Optimism-permissions-migration
	make git-diff before=./reports/Arbitrum_permissions-pre-migration.md after=./reports/Arbitrum_permissions-post-migration.md out=diff-Arbitrum-permissions-migration
clean  :; forge clean
snapshot :; forge snapshot

# scripts
deploy-ava-frax-steward :;  forge script script/DeployAvaFRAXSteward.s.sol:DeployAvaFRAXSteward --rpc-url ${RPC_AVALANCHE} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv
verify-ava-frax-steward :;  forge script script/DeployAvaFRAXSteward.s.sol:DeployAvaFRAXSteward --rpc-url ${RPC_AVALANCHE} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv
deploy-ava-mai-steward :;  forge script script/DeployAvaMAISteward.s.sol:DeployAvaMAISteward --rpc-url ${RPC_AVALANCHE} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv
verify-ava-mai-steward :;  forge script script/DeployAvaMAISteward.s.sol:DeployAvaMAISteward --rpc-url ${RPC_AVALANCHE} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv
deploy-fantom-freeze-steward :;  forge script script/DeployFantomFreezeSteward.s.sol:DeployFantomFreezeSteward --rpc-url ${RPC_FANTOM} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_FANTOM} -vvvv
verify-fantom-freeze-steward :;  forge script script/DeployFantomFreezeSteward.s.sol:DeployFantomFreezeSteward --rpc-url ${RPC_FANTOM} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_FANTOM} -vvvv
deploy-ava-btcb-steward :;  forge script script/DeployAvaBTCbSteward.s.sol:DeployAvaBTCbSteward --rpc-url ${RPC_AVALANCHE} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv
verify-ava-btcb-steward :;  forge script script/DeployAvaBTCbSteward.s.sol:DeployAvaBTCbSteward --rpc-url ${RPC_AVALANCHE} --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv

deploy-permission-migration-op :;  forge script script/DeployPermissionsMigrationPayload.s.sol:DeployOptimismPayload --rpc-url ${RPC_OPTIMISM} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_OPTIMISM} -vvvv
deploy-permission-migration-arb :;  forge script script/DeployPermissionsMigrationPayload.s.sol:DeployArbitrumPayload --rpc-url ${RPC_ARBITRUM} --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_ARBITRUM} -vvvv

# diffs
git-diff :
	@mkdir -p diffs
	@printf '%s\n%s\n%s\n' "\`\`\`diff" "$$(git diff --no-index --diff-algorithm=patience --ignore-space-at-eol ${before} ${after})" "\`\`\`" > diffs/${out}.md
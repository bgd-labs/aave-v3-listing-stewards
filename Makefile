# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build

# IMPORTANT It is highly probable that will be necessary to modify the --fork-block-number, depending on the test
test   :; forge test -vvv --rpc-url=${ETH_RPC_URL} --fork-block-number 16146270
test-susd-collateral :; forge test -vvv --match-contract sUSDAaveV3OptimismEnableAsCollateralByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 14083750
test-frax-ava :; forge test -vvv --match-contract FRAXAaveV3AvaListingByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 17188000
test-frax-fantom :; forge test -vvv --match-contract FRAXAaveV3FantomListingByGuardian --rpc-url=${ETH_RPC_URL} --fork-block-number 42587570
trace   :; forge test -vvvv --rpc-url=${ETH_RPC_URL} --fork-block-number 16146270
clean  :; forge clean
snapshot :; forge snapshot
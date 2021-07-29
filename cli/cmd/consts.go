package cmd

const (
	FUSD_CONTRACT_ADDRESS           = "FUSD_CONTRACT_ADDRESS"
	NFT_CONTRACT_ADDRESS            = "NFT_CONTRACT_ADDRESS"
	FUNGIBLE_TOKEN_CONTRACT_ADDRESS = "FUNGIBLE_TOKEN_CONTRACT_ADDRESS"
	SERVICE_ACCOUNT_ADDRESS         = "SERVICE_ACCOUNT_ADDRESS"

	NON_FUNGIBLE_TOKEN_CONTRACT_NAME = "NonFungibleToken"
	FUNGIBLE_TOKEN_CONTRACT_NAME     = "FungibleToken"
	FUSD_CONTRACT_NAME               = "FUSD"
	SINGLE_CONTRACT_NAME             = "BlockRecordsSingle"
	MARKET_CONTRACT_NAME             = "BlockRecordsMarket"

	LOCAL_FILE_PATH_CONTRACT_DEPLOY = "./cadence/transactions/contract_deploy.cdc"
	LOCAL_FILE_PATH_CONTRACT_UPDATE = "./cadence/transactions/contract_update.cdc"
	LOCAL_FILE_PATH_CONTRACT_REMOVE = "./cadence/transactions/contract_remove.cdc"

	// contracts
	LOCAL_FILE_PATH_SINGLE_MINT                 = "./cadence/transactions/single_mint.cdc"
	LOCAL_FILE_PATH_MARKET_CONTRACT             = "./cadence/contracts/BlockRecordsMarket.cdc"
	LOCAL_FILE_PATH_SINGLE_CONTRACT             = "./cadence/contracts/BlockRecordsSingle.cdc"
	LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT = "./cadence/contracts/NonFungibleToken.cdc"
	LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT     = "./cadence/contracts/FungibleToken.cdc"
	LOCAL_FILE_PATH_FUSD_CONTRACT               = "./cadence/contracts/FUSD.cdc"

	LOCAL_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE = "./cadence/scripts/read_account_fusd_balance.cdc"
)

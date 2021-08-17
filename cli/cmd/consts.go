package cmd

const (
	FUSD_CONTRACT_ADDRESS           = "FUSD_CONTRACT_ADDRESS"
	NFT_CONTRACT_ADDRESS            = "NFT_CONTRACT_ADDRESS"
	FUNGIBLE_TOKEN_CONTRACT_ADDRESS = "FUNGIBLE_TOKEN_CONTRACT_ADDRESS"
	SERVICE_ACCOUNT_ADDRESS         = "SERVICE_ACCOUNT_ADDRESS"

	NFT_CONTRACT_NAME            = "NonFungibleToken"
	FUNGIBLE_TOKEN_CONTRACT_NAME = "FungibleToken"
	FUSD_CONTRACT_NAME           = "FUSD"

	BR_NFT_CONTRACT_NAME          = "BlockRecordsNFT"
	BR_MARKETPLACE_CONTRACT_NAME  = "BlockRecordsMarketplace"
	BR_RELEASE_CONTRACT_NAME      = "BlockRecordsRelease"
	BR_SALE_LISTING_CONTRACT_NAME = "BlockRecordsSaleListing"

	// standard contracts
	LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT = "./cadence/contracts/NonFungibleToken.cdc"
	LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT     = "./cadence/contracts/FungibleToken.cdc"
	LOCAL_FILE_PATH_FUSD_CONTRACT               = "./cadence/contracts/FUSD.cdc"

	// br contracts
	LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT  = "./cadence/contracts/BlockRecordsMarketplace.cdc"
	LOCAL_FILE_PATH_BR_NFT_CONTRACT          = "./cadence/contracts/BlockRecordsNFT.cdc"
	LOCAL_FILE_PATH_BR_RELEASE_CONTRACT      = "./cadence/contracts/BlockRecordsRelease.cdc"
	LOCAL_FILE_PATH_BR_SALE_LISTING_CONTRACT = "./cadence/contracts/BlockRecordsSaleListing.cdc"

	// txs
	LOCAL_FILE_PATH_SINGLE_MINT     = "./cadence/transactions/single_mint.cdc"
	LOCAL_FILE_PATH_CONTRACT_DEPLOY = "./cadence/transactions/contract_deploy.cdc"
	LOCAL_FILE_PATH_CONTRACT_UPDATE = "./cadence/transactions/contract_update.cdc"
	LOCAL_FILE_PATH_CONTRACT_REMOVE = "./cadence/transactions/contract_remove.cdc"

	// scripts
	LOCAL_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE = "./cadence/scripts/read_account_fusd_balance.cdc"
)

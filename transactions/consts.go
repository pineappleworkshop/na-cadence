package transactions

const (
	SERVICE_ACCOUNT_ADDRESS         = "SERVICE_ACCOUNT_ADDRESS"
	FUSD_CONTRACT_ADDRESS           = "FUSD_CONTRACT_ADDRESS"
	NFT_CONTRACT_ADDRESS            = "NFT_CONTRACT_ADDRESS"
	FUNGIBLE_TOKEN_CONTRACT_ADDRESS = "FUNGIBLE_TOKEN_CONTRACT_ADDRESS"
	CREATOR_ACCOUNT_ADDRESS         = "CREATOR_ACCOUNT_ADDRESS"

	TEST_FILE_PATH_MARKET_CONTRACT    = "../cadence/contracts/BlockRecordsMarket.cdc"
	LOCAL_FILE_PATH_MARKET_CONTRACT   = "./cadence/contracts/BlockRecordsMarket.cdc"
	CLUSTER_FILE_PATH_MARKET_CONTRACT = "./go/bin/contracts/BlockRecordsMarket.cdc"
	MARKET_CONTRACT_NAME              = "BlockRecordsMarket"

	TEST_FILE_PATH_BR_NFT_CONTRACT    = "../cadence/contracts/BlockRecordsNFT.cdc"
	LOCAL_FILE_PATH_BR_NFT_CONTRACT   = "./cadence/contracts/BlockRecordsNFT.cdc"
	CLUSTER_FILE_PATH_BR_NFT_CONTRACT = "./go/bin/contracts/BlockRecordsNFT.cdc"
	BR_NFT_CONTRACT_NAME              = "BlockRecordsNFT"

	TEST_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT    = "../cadence/contracts/NonFungibleToken.cdc"
	LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT   = "./cadence/contracts/NonFungibleToken.cdc"
	CLUSTER_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT = "./go/bin/contracts/NonFungibleToken.cdc"
	NON_FUNGIBLE_TOKEN_CONTRACT_NAME              = "NonFungibleToken"

	TEST_FILE_PATH_CONTRACT_DEPLOY    = "../cadence/transactions/contract_deploy.cdc"
	LOCAL_FILE_PATH_CONTRACT_DEPLOY   = "./cadence/transactions/contract_deploy.cdc"
	CLUSTER_FILE_PATH_CONTRACT_DEPLOY = "./go/bin/transactions/contract_deploy.cdc"

	TEST_FILE_PATH_CONTRACT_UPDATE    = "../cadence/transactions/contract_update.cdc"
	LOCAL_FILE_PATH_CONTRACT_UPDATE   = "./cadence/transactions/contract_update.cdc"
	CLUSTER_FILE_PATH_CONTRACT_UPDATE = "./go/bin/transactions/contract_update.cdc"

	TEST_FILE_PATH_ACCOUNT_INITIALIZE    = "../cadence/transactions/account_initialize.cdc"
	LOCAL_FILE_PATH_ACCOUNT_INITIALIZE   = "./cadence/transactions/account_initialize.cdc"
	CLUSTER_FILE_PATH_ACCOUNT_INITIALIZE = "go/bin/cadence/transactions/account_initialize.cdc"

	TEST_FILE_PATH_CREATOR_SETUP    = "../cadence/transactions/creator_setup.cdc"
	LOCAL_FILE_PATH_CREATOR_SETUP   = "./cadence/transactions/creator_setup.cdc"
	CLUSTER_FILE_PATH_CREATOR_SETUP = "go/bin/cadence/transactions/creator_setup.cdc"

	TEST_FILE_PATH_CREATOR_AUTHORIZE    = "../cadence/transactions/creator_authorize.cdc"
	LOCAL_FILE_PATH_CREATOR_AUTHORIZE   = "./cadence/transactions/creator_authorize.cdc"
	CLUSTER_FILE_PATH_CREATOR_AUTHORIZE = "go/bin/cadence/transactions/creator_authorize.cdc"

	TEST_FILE_PATH_CREATOR_DEAUTHORIZE    = "../cadence/transactions/creator_deauthorize.cdc"
	LOCAL_FILE_PATH_CREATOR_DEAUTHORIZE   = "./cadence/transactions/creator_deauthorize.cdc"
	CLUSTER_FILE_PATH_CREATOR_DEAUTHORIZE = "go/bin/cadence/transactions/creator_deauthorize.cdc"

	TEST_FILE_PATH_SINGLE_MINT    = "../cadence/transactions/single_mint.cdc"
	LOCAL_FILE_PATH_SINGLE_MINT   = "./cadence/transactions/single_mint.cdc"
	CLUSTER_FILE_PATH_SINGLE_MINT = "./go/bin/cadence/transactions/single_mint.cdc"

	TEST_FILE_PATH_FUSD_DEPOSIT    = "../cadence/transactions/fusd_deposit.cdc"
	LOCAL_FILE_PATH_FUSD_DEPOSIT   = "./cadence/transactions/fusd_deposit.cdc"
	CLUSTER_FILE_PATH_FUSD_DEPOSIT = "./go/bin/cadence/transactions/fusd_deposit.cdc"

	TEST_FILE_PATH_RELEASE_CREATE    = "../cadence/transactions/release_create.cdc"
	LOCAL_FILE_PATH_RELEASE_CREATE   = "./cadence/transactions/release_create.cdc"
	CLUSTER_FILE_PATH_RELEASE_CREATE = "./go/bin/cadence/transactions/release_create.cdc"

	TEST_FILE_PATH_SALE_LISTING_CREATE    = "../cadence/transactions/sale_listing_create.cdc"
	LOCAL_FILE_PATH_SALE_LISTING_CREATE   = "./cadence/transactions/sale_listing_create.cdc"
	CLUSTER_FILE_PATH_SALE_LISTING_CREATE = "go/bin/cadence/transactions/sale_listing_create.cdc"

	TEST_FILE_PATH_SALE_LISTING_BUY    = "../cadence/transactions/sale_listing_buy.cdc"
	LOCAL_FILE_PATH_SALE_LISTING_BUY   = "./cadence/transactions/sale_listing_buy.cdc"
	CLUSTER_FILE_PATH_SALE_LISTING_BUY = "go/bin/cadence/transactions/sale_listing_buy.cdc"

	TEST_FILE_PATH_SALE_LISTING_DESTROY    = "../cadence/transactions/sale_listing_destroy.cdc"
	LOCAL_FILE_PATH_SALE_LISTING_DESTROY   = "./cadence/transactions/sale_listing_destroy.cdc"
	CLUSTER_FILE_PATH_SALE_LISTING_DESTROY = "go/bin/cadence/transactions/sale_listing_destroy.cdc"

	TEST_SINGLE_NAME               = "Block Records Single Test"
	TEST_SINGLE_ROYALTY_PERCENTAGE = 5
	TEST_SINGLE_TYPE               = "Single"
	TEST_SINGLE_LITERATION         = "This is a test Block Records Single"
	TEST_SINGLE_IMAGE_URL          = "https://test.image.com"
	TEST_SINGLE_AUDIO_URL          = "https://test.audio.com"
	TEST_SINGLE_COPIES_COUNT       = 3

	TEST_CREATOR_PROFILE_STAGE_NAME = "robbie wasabi"
	TEST_CREATOR_PROFILE_FULL_NAME  = "Robert Rossilli"
	TEST_CREATOR_PROFILE_IMAGE      = "https://ipfs.io/ipfs/Qmc4EA9rNdHVDKQUDWDgeGyL7pL1FDFMkT2ZnWC61DvaQd"

	TEST_FUSD_AMOUNT = 10000
)

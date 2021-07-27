package scripts

const (
	FUSD_CONTRACT_ADDRESS               = "FUSD_CONTRACT_ADDRESS"
	NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS = "NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS"
	FUNGIBLE_TOKEN_CONTRACT_ADDRESS     = "FUNGIBLE_TOKEN_CONTRACT_ADDRESS"
	SERVICE_ACCOUNT_ADDRESS             = "SERVICE_ACCOUNT_ADDRESS"
	ACCOUNT_ADDRESS                     = "ACCOUNT_ADDRESS"
	SINGLE_ID                           = "SINGLE_ID"

	LOCAL_FILE_PATH_READ_SINGLES_SUPPLY   = "./cadence/scripts/read_singles_supply.cdc"
	CLUSTER_FILE_PATH_READ_SINGLES_SUPPLY = "./go/bin/cadence/scripts/read_singles_supply.cdc"

	LOCAL_FILE_PATH_READ_ACCOUNT_SINGLE   = "./cadence/scripts/read_account_single.cdc"
	CLUSTER_FILE_PATH_READ_ACCOUNT_SINGLE = "./go/bin/cadence/scripts/read_account_single.cdc"

	LOCAL_FILE_PATH_READ_ACCOUNT_SINGLES   = "./cadence/scripts/read_account_singles.cdc"
	CLUSTER_FILE_PATH_READ_ACCOUNT_SINGLES = "./go/bin/cadence/scripts/read_account_singles.cdc"

	LOCAL_FILE_PATH_READ_ACCOUNT_SALE_LISTING   = "./cadence/scripts/read_account_sale_listing.cdc"
	CLUSTER_FILE_PATH_READ_ACCOUNT_SALE_LISTING = "./go/bin/cadence/scripts/read_account_sale_listing.cdc"

	LOCAL_FILE_PATH_READ_ACCOUNT_SALE_LISTINGS   = "./cadence/scripts/read_account_sale_listings.cdc"
	CLUSTER_FILE_PATH_READ_ACCOUNT_SALE_LISTINGS = "./go/bin/cadence/scripts/read_account_sale_listings.cdc"

	TEST_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE    = "../cadence/scripts/read_account_fusd_balance.cdc"
	LOCAL_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE   = "./cadence/scripts/read_account_fusd_balance.cdc"
	CLUSTER_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE = "./go/bin/cadence/scripts/read_account_fusd_balance.cdc"

	TEST_FILE_PATH_READ_ACCOUNT_STATUS    = "../cadence/scripts/read_account_status.cdc"
	LOCAL_FILE_PATH_READ_ACCOUNT_STATUS   = "./cadence/scripts/read_account_status.cdc"
	CLUSTER_FILE_PATH_READ_ACCOUNT_STATUS = "./go/bin/cadence/scripts/read_account_status.cdc"

	TEST_FUSD_AMOUNT = 10000
)

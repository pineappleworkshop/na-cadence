package config

const (
	VERSION      = "0.0.3"
	PORT         = 3444
	SERVICE_NAME = "na-cadence"

	TEST        = "test"
	WORKSTATION = "workstation"
	DEV         = "dev"
	STAGE       = "stage"
	PROD        = "prod"

	CONSUL_KV           = "na"
	CONSUL_HOST_DEV     = "localhost"
	CONSUL_PORT_DEV     = "8500"
	CONSUL_HOST_CLUSTER = "consul-server"
	CONSUL_PORT_CLUSTER = "8500"

	FLOW_HASH_ALGO_NAME          = "SHA3_256"
	FLOW_SIG_ALGO_NAME           = "ECDSA_P256"
	FLOW_SERVICE_ACCOUNT_SIG_ALG = "ECDSA_P256"
	FLOW_GAS_LIMIT               = uint64(1000)
	FLOW_NFT_NAME                = "BlockRecordsSingle"
	FLOW_COLLECTION_NAME         = "BlockRecordsSingleCollection002"
	IPFS_BASE_URL                = "https://ipfs.io/ipfs/"

	FUSD_CONTRACT_ADDRESS_TESTNET = "0xe223d8a629e49c68"
	FUSD_CONTRACT_ADDRESS_MAINNET = "0x3c5959b568896393"

	FUNGIBLE_TOKEN_CONTRACT_ADDRESS_TESTNET = "0x9a0766d93b6608b7"
	FUNGIBLE_TOKEN_CONTRACT_ADDRESS_MAINNET = "0xf233dcee88fe0abe"

	// todo: verify
	NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS_TESTNET = "./"
	NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS_MAINNET = "./"

	BLOCK_RECORDS_VERSION = "1"
)

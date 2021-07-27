package transactions

import (
	"io/ioutil"
	"na-cadence/config"
	"strings"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
)

type SaleListingCreate struct {
	ID    cadence.UInt64
	Price cadence.UFix64
}

func CreateSaleListing(serviceAcctAddr, creatorAcctAddr, creatorAcctPrivKey string, saleListing SaleListingCreate) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_SALE_LISTING_CREATE
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_SALE_LISTING_CREATE
	} else {
		filePath = LOCAL_FILE_PATH_SALE_LISTING_CREATE
	}

	txFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	txFileStr := strings.Replace(
		string(txFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
		-1,
	)

	//create authorizers
	authorizerAddress := flow.HexToAddress(creatorAcctAddr)
	var authorizers []flow.Address
	authorizers = []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(txFileStr), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	// todo: cleaner way to do this
	tx.AddArgument(saleListing.ID)
	tx.AddArgument(saleListing.Price)

	//create signers
	authorizerSigner, err := createSigner(authorizerAddress, creatorAcctPrivKey)
	signers := []crypto.Signer{
		authorizerSigner,
	}
	signerAddrs := []flow.Address{
		*&authorizerAddress,
	}

	//sign and submit transaction
	result, err := signAndSubmit(tx, signerAddrs, signers)
	if err != nil {
		return nil, err
	}

	return result, nil
}

func DestroySaleListing(serviceAcctAddr, ownerAcctAddr, ownerAcctPrivKey string, saleListingID cadence.UInt64) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_SALE_LISTING_DESTROY
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_SALE_LISTING_DESTROY
	} else {
		filePath = LOCAL_FILE_PATH_SALE_LISTING_DESTROY
	}

	txFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	txFileStr := strings.Replace(
		string(txFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)

	//create authorizers
	authorizerAddress := flow.HexToAddress(ownerAcctAddr)
	var authorizers []flow.Address
	authorizers = []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(txFileStr), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	tx.AddArgument(saleListingID)

	//create signers
	authorizerSigner, err := createSigner(authorizerAddress, ownerAcctPrivKey)
	signers := []crypto.Signer{
		authorizerSigner,
	}
	signerAddrs := []flow.Address{
		*&authorizerAddress,
	}

	//sign and submit transaction
	result, err := signAndSubmit(tx, signerAddrs, signers)
	if err != nil {
		return nil, err
	}

	return result, nil
}

func BuySaleListing(serviceAcctAddr, buyAcctAddr, buyerAcctPrivKey string, saleListingID cadence.UInt64, saleListingAcctAddress cadence.Address) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_SALE_LISTING_BUY
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_SALE_LISTING_BUY
	} else {
		filePath = LOCAL_FILE_PATH_SALE_LISTING_BUY
	}

	txFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	txFileStr := strings.Replace(
		string(txFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
		-1,
	)

	//create authorizers
	authorizerAddress := flow.HexToAddress(buyAcctAddr)
	var authorizers []flow.Address
	authorizers = []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(txFileStr), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	tx.AddArgument(saleListingID)
	tx.AddArgument(saleListingAcctAddress)

	//create signers
	authorizerSigner, err := createSigner(authorizerAddress, buyerAcctPrivKey)
	signers := []crypto.Signer{
		authorizerSigner,
	}
	signerAddrs := []flow.Address{
		*&authorizerAddress,
	}

	//sign and submit transaction
	result, err := signAndSubmit(tx, signerAddrs, signers)
	if err != nil {
		return nil, err
	}

	return result, nil
}

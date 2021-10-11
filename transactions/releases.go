package transactions

import (
	"io/ioutil"
	"na-cadence/config"
	"strings"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk/crypto"

	"github.com/onflow/flow-go-sdk"
)

type ReleaseCreate struct {
	Type              cadence.String
	Name              cadence.String
	Literation        cadence.String
	Image             cadence.String
	Audio             cadence.String
	CopiesCount       cadence.Int
	PayoutAddresses   cadence.Array
	PayoutPercentFees cadence.Array
}

func CreateRelease(serviceAcctAddr, creatorAcctAddr, creatorAcctPrivKey string, release ReleaseCreate) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_RELEASE_CREATE
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_RELEASE_CREATE
	} else {
		filePath = LOCAL_FILE_PATH_RELEASE_CREATE
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
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
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
		NFT_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
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

	tx.AddArgument(release.Type)
	tx.AddArgument(release.Name)
	tx.AddArgument(release.Literation)
	tx.AddArgument(release.Image)
	tx.AddArgument(release.Audio)
	tx.AddArgument(release.CopiesCount)
	tx.AddArgument(release.PayoutAddresses)
	tx.AddArgument(release.PayoutPercentFees)
	tx.AddArgument(cadence.Address(authorizerAddress))

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

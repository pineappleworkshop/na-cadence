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
	Type             cadence.String
	Name             cadence.String
	Literation       cadence.String
	ImageURL         cadence.String
	AudioURL         cadence.String
	CopiesCount      cadence.UInt64
	PayoutAddress    cadence.Address
	PayoutPercentFee cadence.UFix64
	ReceiverAddress  cadence.Address
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
	tx.AddArgument(release.ImageURL)
	tx.AddArgument(release.AudioURL)
	tx.AddArgument(release.CopiesCount)
	tx.AddArgument(release.PayoutAddress)
	tx.AddArgument(release.PayoutPercentFee)
	tx.AddArgument(release.ReceiverAddress)

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

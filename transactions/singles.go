package transactions

import (
	"io/ioutil"
	"na-cadence/config"
	"strings"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk/crypto"

	"github.com/onflow/flow-go-sdk"
)

type NFTCreate struct {
	Name                   cadence.String
	ReceiverAccountAddress cadence.Address
	RoyaltyAddress         cadence.Address
	RoyaltyPercentage      cadence.UInt64
	Type                   cadence.String
	Literation             cadence.String
	ImageURL               cadence.String
	AudioURL               cadence.String
}

func MintSingle(serviceAcctAddr, minterAcctAddr, minterAcctPrivKey string, nft NFTCreate) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_SINGLE_MINT
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_SINGLE_MINT
	} else {
		filePath = LOCAL_FILE_PATH_SINGLE_MINT
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
		NFT_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)

	//create authorizers
	authorizerAddress := flow.HexToAddress(minterAcctAddr)
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
	tx.AddArgument(nft.Name)
	tx.AddArgument(nft.ReceiverAccountAddress)
	tx.AddArgument(nft.RoyaltyAddress)
	tx.AddArgument(nft.RoyaltyPercentage)
	tx.AddArgument(nft.Type)
	tx.AddArgument(nft.Literation)
	tx.AddArgument(nft.ImageURL)
	tx.AddArgument(nft.AudioURL)

	//create signers
	authorizerSigner, err := createSigner(authorizerAddress, minterAcctPrivKey)
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

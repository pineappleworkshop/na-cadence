package transactions

import (
	"io/ioutil"
	"na-cadence/config"
	"strings"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
)

func DepositFUSDIntoAccount(serviceAcctAddr, serviceAcctPrivKey string, receiverAccountAddr flow.Address, amount cadence.UFix64) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_FUSD_DEPOSIT
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_FUSD_DEPOSIT
	} else {
		filePath = LOCAL_FILE_PATH_FUSD_DEPOSIT
	}

	txFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	txFileStr := strings.Replace(
		string(txFile),
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
	authorizerAddress := flow.HexToAddress(serviceAcctAddr)
	var authorizers []flow.Address
	authorizers = []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(txFileStr), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	tx.AddArgument(amount)
	tx.AddArgument(cadence.Address(receiverAccountAddr))

	//create signers
	authorizerSigner, err := createSigner(authorizerAddress, serviceAcctPrivKey)
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

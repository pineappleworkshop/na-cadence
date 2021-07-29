package transactions

import (
	"context"
	"fmt"
	"io/ioutil"
	"na-cadence/config"
	"strings"

	tmps "github.com/onflow/flow-go-sdk/templates"

	"github.com/onflow/flow-go-sdk/client"
	"github.com/onflow/flow-go-sdk/crypto"
	"google.golang.org/grpc"

	"github.com/onflow/flow-go-sdk"
)

func CreateAccount(
	node string,
	publicKeyHex *string,
	sigAlgoName string,
	hashAlgoName string,
	contracts []tmps.Contract,
	serviceAddressHex string,
	servicePrivKeyHex string,
	serviceSigAlgoName string,
	gasLimit uint64) (*flow.Address, error) {

	ctx := context.Background()

	hashAlgo := crypto.StringToHashAlgorithm(hashAlgoName)

	c, err := client.New(node, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	serviceSigAlgo := crypto.StringToSignatureAlgorithm(serviceSigAlgoName)
	servicePrivKey, err := crypto.DecodePrivateKeyHex(serviceSigAlgo, servicePrivKeyHex)
	if err != nil {
		return nil, err
	}

	serviceAddress := flow.HexToAddress(serviceAddressHex)
	serviceAccount, err := c.GetAccountAtLatestBlock(ctx, serviceAddress)
	if err != nil {
		return nil, err
	}

	serviceAccountKey := serviceAccount.Keys[0]
	serviceSigner := crypto.NewInMemorySigner(servicePrivKey, serviceAccountKey.HashAlgo)

	// Get the latest sealed block to use as a reference block
	latestBlock, err := c.GetLatestBlockHeader(context.Background(), true)
	if err != nil {
		return nil, err
	}

	sigAlgo := crypto.StringToSignatureAlgorithm(serviceSigAlgoName)
	var publicKeys []*flow.AccountKey
	if publicKeyHex != nil {
		publicKey, err := crypto.DecodePublicKeyHex(sigAlgo, *publicKeyHex)
		if err != nil {
			return nil, err
		}
		accountKey := flow.NewAccountKey().
			SetPublicKey(publicKey).
			SetSigAlgo(sigAlgo).
			SetHashAlgo(hashAlgo).
			SetWeight(flow.AccountKeyWeightThreshold)

		publicKeys = []*flow.AccountKey{accountKey}
	}

	tx := tmps.CreateAccount(publicKeys, contracts, serviceAddress)
	tx.SetProposalKey(serviceAddress, serviceAccountKey.Index, serviceAccountKey.SequenceNumber)
	tx.SetPayer(serviceAddress)
	tx.SetGasLimit(uint64(gasLimit))
	tx.SetReferenceBlockID(latestBlock.ID)

	err = tx.SignEnvelope(serviceAddress, serviceAccountKey.Index, serviceSigner)
	if err != nil {
		return nil, err
	}

	err = c.SendTransaction(ctx, *tx)
	if err != nil {
		return nil, err
	}

	result, err := c.GetTransactionResult(ctx, tx.ID())
	if err != nil {
		return nil, err
	}
	fmt.Println(result)
	fmt.Println("trans id", tx.ID())

	var address flow.Address

	if result.Status == flow.TransactionStatusSealed {
		for _, event := range result.Events {
			if event.Type == flow.EventAccountCreated {
				accountCreatedEvent := flow.AccountCreatedEvent(event)
				address = accountCreatedEvent.Address()
			}
		}
	}

	return &address, err
}

func InitializeAccount(serviceAcctAddr string, targetAcctAddr flow.Address, targetAcctPrivKey string) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_ACCOUNT_INITIALIZE
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_ACCOUNT_INITIALIZE
	} else {
		filePath = LOCAL_FILE_PATH_ACCOUNT_INITIALIZE
	}

	txFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}

	txFileStr := strings.Replace(
		string(txFile),
		SERVICE_ACCOUNT_ADDRESS,
		config.Conf.FlowServiceAccountAddress,
		-1,
	)
	txFileStr = strings.Replace(
		txFileStr,
		NFT_CONTRACT_ADDRESS,
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

	var authorizers []flow.Address
	authorizers = []flow.Address{
		targetAcctAddr,
	}

	tx, err := createTransaction([]byte(txFileStr), &targetAcctAddr, &authorizers)
	if err != nil {
		return nil, err
	}

	authorizerSigner, err := createSigner(targetAcctAddr, targetAcctPrivKey)
	signers := []crypto.Signer{
		authorizerSigner,
	}
	signerAddrs := []flow.Address{
		targetAcctAddr,
	}

	txRes, err := signAndSubmit(tx, signerAddrs, signers)
	if err != nil {
		return nil, err
	}

	return txRes, nil
}

func AuthorizeMinter(serviceAcctAddr string, targetAcctAddress flow.Address, targetAcctPrivKey string) (*flow.TransactionResult, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_MINTER_AUTHORIZE
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_MINTER_AUTHORIZE
	} else {
		filePath = LOCAL_FILE_PATH_MINTER_AUTHORIZE
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
		string(txFileStr),
		NFT_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)

	var authorizers []flow.Address
	authorizers = []flow.Address{
		targetAcctAddress,
	}

	tx, err := createTransaction([]byte(txFileStr), &targetAcctAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	authorizerSigner, err := createSigner(targetAcctAddress, targetAcctPrivKey)
	signers := []crypto.Signer{
		authorizerSigner,
	}
	signerAddrs := []flow.Address{
		targetAcctAddress,
	}

	result, err := signAndSubmit(tx, signerAddrs, signers)
	if err != nil {
		return nil, err
	}

	return result, nil
}

package cmd

import (
	"context"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"na-cadence/config"
	"strings"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/client"
	"github.com/onflow/flow-go-sdk/crypto"
	"google.golang.org/grpc"
)

func DeployContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, contractName string) (*flow.TransactionResult, error) {
	contractFile, err := ioutil.ReadFile(contractFilePath)
	if err != nil {
		return nil, err
	}

	contractFileStr := strings.Replace(
		string(contractFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)
	contractFileStr = strings.Replace(
		contractFileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	contractFileStr = strings.Replace(
		contractFileStr,
		NFT_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)
	contractFileStr = strings.Replace(
		contractFileStr,
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
		-1,
	)

	txFile, err := ioutil.ReadFile(LOCAL_FILE_PATH_CONTRACT_DEPLOY)
	if err != nil {
		return nil, err
	}

	//create authorizers
	authorizerAddress := flow.HexToAddress(serviceAcctAddr)
	var authorizers []flow.Address
	authorizers = []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(string(txFile)), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	tx.AddArgument(cadence.String(contractName))
	tx.AddArgument(cadence.String(hex.EncodeToString([]byte(contractFileStr)))) // todo

	// fmt.Println(string(tx.Script))
	// fmt.Println(contractFileStr)

	//create signers
	serviceAddr := flow.HexToAddress(serviceAcctAddr)
	serviceSigner, err := createSigner(serviceAddr, serviceAcctPrivKey)
	signers := []crypto.Signer{
		serviceSigner,
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

func UpdateContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, contractName string) (*flow.TransactionResult, error) {
	contractFile, err := ioutil.ReadFile(contractFilePath)
	if err != nil {
		return nil, err
	}

	contractFileStr := strings.Replace(
		string(contractFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)
	contractFileStr = strings.Replace(
		contractFileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	contractFileStr = strings.Replace(
		contractFileStr,
		NFT_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)
	contractFileStr = strings.Replace(
		contractFileStr,
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
		-1,
	)

	txFile, err := ioutil.ReadFile(LOCAL_FILE_PATH_CONTRACT_UPDATE)
	if err != nil {
		return nil, err
	}

	//create authorizers
	authorizerAddress := flow.HexToAddress(serviceAcctAddr)
	var authorizers []flow.Address
	authorizers = []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(string(txFile)), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	tx.AddArgument(cadence.String(contractName))
	tx.AddArgument(cadence.String(hex.EncodeToString([]byte(contractFileStr)))) // todo

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

func RemoveContract(serviceAcctAddr, serviceAcctPrivKey, contractName string) (*flow.TransactionResult, error) {
	txFile, err := ioutil.ReadFile(LOCAL_FILE_PATH_CONTRACT_REMOVE)
	if err != nil {
		return nil, err
	}

	//create authorizers
	authorizerAddress := flow.HexToAddress(serviceAcctAddr)
	authorizers := []flow.Address{
		authorizerAddress,
	}

	//create transaction
	tx, err := createTransaction([]byte(string(txFile)), &authorizerAddress, &authorizers)
	if err != nil {
		return nil, err
	}

	tx.AddArgument(cadence.String(contractName))

	//create signers
	serviceAddr := flow.HexToAddress(serviceAcctAddr)
	serviceSigner, err := createSigner(serviceAddr, serviceAcctPrivKey)
	signers := []crypto.Signer{
		serviceSigner,
	}
	signerAddrs := []flow.Address{
		*&authorizerAddress,
	}

	//sign and submit transaction
	result, err := signAndSubmit(tx, signerAddrs, signers)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

func ReadAccountFUSDBalance(serviceAcctAddr, acctAddr string) (cadence.Value, error) {
	filePath := LOCAL_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE

	scriptFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	scriptFileStr := strings.Replace(
		string(scriptFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)

	// todo: add params

	scriptResult, err := ExecuteScript([]byte(scriptFileStr))
	if err != nil {
		return nil, err
	}

	return scriptResult, nil
}

//IMPORTANT
//The number of authorizers on the transaction must match the number of
//AuthAccount parameters declared in the prepare statement of the Cadence script.
//depending on how many accounts the transaction needs to access.
func createTransaction(script []byte, proposerAddr *flow.Address, authorizerAddresses *[]flow.Address) (*flow.Transaction, error) {
	ctx := context.Background()
	c, err := client.New(config.Conf.FlowAccessNode, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	//A transaction must specify a sequence number to prevent replays and other potential attacks.
	//Each account key maintains a separate transaction sequence counter;
	//the key that lends its sequence number to a transaction is called the proposal key.
	//we'll default this to the payer
	payerAccount, err := c.GetAccountAtLatestBlock(ctx, *proposerAddr)
	if err != nil {
		return nil, err
	}
	proposalKey := payerAccount.Keys[0]

	//A transaction must specify an expiration window (measured in blocks) during which it is considered valid by the network.
	//A transaction will be rejected if it is submitted past its expiry block.
	latestBlock, err := c.GetLatestBlockHeader(context.Background(), true)
	if err != nil {
		return nil, err
	}

	tx := flow.NewTransaction().
		SetScript([]byte(script)).
		SetProposalKey(*proposerAddr, proposalKey.Index, proposalKey.SequenceNumber).
		SetPayer(*proposerAddr).                    //proposer will be default transaction funder for now...
		SetGasLimit(uint64(config.FLOW_GAS_LIMIT)). //gas limit will be a const for now...
		SetReferenceBlockID(latestBlock.ID)

	// add authorizer addresses
	for _, addr := range *authorizerAddresses {
		tx.AddAuthorizer(addr)
	}

	return tx, nil
}

func createSigner(addr flow.Address, privKey string) (*crypto.InMemorySigner, error) {
	ctx := context.Background()
	c, err := client.New(config.Conf.FlowAccessNode, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	flowAddr := flow.HexToAddress(addr.Hex())
	acct, err := c.GetAccountAtLatestBlock(ctx, flowAddr)
	if err != nil {
		return nil, err
	}

	sigAlgo := crypto.StringToSignatureAlgorithm(config.FLOW_SERVICE_ACCOUNT_SIG_ALG)
	decodedPrivKey, err := crypto.DecodePrivateKeyHex(sigAlgo, privKey)
	if err != nil {
		return nil, err
	}

	acctKey := acct.Keys[0]
	inMemSighner := crypto.NewInMemorySigner(decodedPrivKey, acctKey.HashAlgo)

	signer := inMemSighner

	return &signer, nil
}

// func executeTransaction(tx flow.Transaction,
// 	proposerAddr *flow.Address,
// 	authorizerAddresses *[]flow.Address,
// 	signers *[]crypto.Signer) (*flow.TransactionResult, error) {
// 	// validate input values
// 	// acctAddrParsed := flow.HexToAddress(acctAddr)
// 	// todo: through err if not legit
// 	// todo: see if we can validate the private key

// 	// tx, err := createTransaction(script, proposerAddr, authorizerAddresses)
// 	// if err != nil {
// 	// 	return nil, err
// 	// }

// 	// result, err := signAndSubmit(tx, &signers, *signers)
// 	// if err != nil {
// 	// 	return nil, err
// 	// }

// 	return result, nil
// }

func signAndSubmit(tx *flow.Transaction,
	signerAddresses []flow.Address,
	signers []crypto.Signer,
) (*flow.TransactionResult, error) {

	// sign transaction with each signer
	for i := len(signerAddresses) - 1; i >= 0; i-- {
		signerAddress := signerAddresses[i]
		signer := signers[i]

		if i == 0 {
			if err := tx.SignEnvelope(signerAddress, 0, signer); err != nil {
				fmt.Println(err)
			}
		} else {
			if err := tx.SignPayload(signerAddress, 0, signer); err != nil {
				fmt.Println(err)
			}
		}
	}
	result, err := submit(tx)
	if err != nil {
		return nil, err
	}

	return result, nil
}

func submit(tx *flow.Transaction) (*flow.TransactionResult, error) {
	ctx := context.Background()

	c, err := client.New(config.Conf.FlowAccessNode, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}
	err = c.SendTransaction(ctx, *tx)
	if err != nil {
		return nil, err
	}

	txID := flow.HexToID(tx.ID().Hex())
	result, err := c.GetTransactionResult(ctx, txID)
	if err != nil {
		return nil, err
	}

	return result, nil
}

func ExecuteScript(script []byte) (cadence.Value, error) {
	ctx := context.Background()
	c, err := client.New(config.Conf.FlowAccessNode, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	byteScript := script

	result, err := c.ExecuteScriptAtLatestBlock(ctx, byteScript, nil)
	if err != nil {
		return nil, err
	}

	return result, nil
}

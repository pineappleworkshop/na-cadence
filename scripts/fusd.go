package scripts

import (
	"context"
	"io/ioutil"
	"na-cadence/config"
	"strconv"
	"strings"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/client"
	"google.golang.org/grpc"
)

func ReadAccountFUSDBalance(serviceAcctAddr string, acctAddr flow.Address) (*float64, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE
	} else {
		filePath = LOCAL_FILE_PATH_READ_ACCOUNT_FUSD_BALANCE
	}

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
	scriptFileStr = strings.Replace(
		scriptFileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	scriptFileStr = strings.Replace(
		scriptFileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	scriptFileStr = strings.Replace(
		scriptFileStr,
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
		-1,
	)

	ctx := context.Background()
	c, err := client.New(config.Conf.FlowAccessNode, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	args := []cadence.Value{
		cadence.Address(acctAddr),
	}

	result, err := c.ExecuteScriptAtLatestBlock(ctx, []byte(scriptFileStr), args)
	if err != nil {
		return nil, err
	}

	balanceString := result.(cadence.UFix64).String()

	balance, err := strconv.ParseFloat(balanceString, 64)
	if err != nil {
		return nil, err
	}

	return &balance, nil
}

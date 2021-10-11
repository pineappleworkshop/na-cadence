package scripts

import (
	"io/ioutil"
	"na-cadence/config"
	"strings"

	"github.com/onflow/cadence"
)

func GetSingleTotalSupplyIDs(serviceAcctAddr string) (cadence.Value, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_READ_SINGLES_SUPPLY
	} else {
		filePath = LOCAL_FILE_PATH_READ_SINGLES_SUPPLY
	}

	transactionFile, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	transactionFileStr := strings.Replace(
		string(transactionFile),
		SERVICE_ACCOUNT_ADDRESS,
		serviceAcctAddr,
		-1,
	)

	scriptResult, err := ExecuteScript([]byte(transactionFileStr))
	if err != nil {
		return nil, err
	}

	return scriptResult, nil
}

func GetSinglesByAccountAddress(serviceAcctAddr, acctAddr string) (cadence.Value, error) {
	var filePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		filePath = CLUSTER_FILE_PATH_READ_ACCOUNT_SINGLES
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = TEST_FILE_PATH_READ_ACCOUNT_SINGLES
	} else {
		filePath = LOCAL_FILE_PATH_READ_ACCOUNT_SINGLES
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
		NFT_CONTRACT_ADDRESS,
		config.Conf.FlowServiceAccountAddress,
		-1,
	)
	scriptFileStr = strings.Replace(
		scriptFileStr,
		SERVICE_ACCOUNT_ADDRESS,
		config.Conf.FlowServiceAccountAddress,
		-1,
	)
	scriptFileStr = strings.Replace(
		scriptFileStr,
		ACCOUNT_ADDRESS,
		acctAddr,
		-1,
	)

	scriptResult, err := ExecuteScript([]byte(scriptFileStr))
	if err != nil {
		return nil, err
	}

	return scriptResult, nil
}

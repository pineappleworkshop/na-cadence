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

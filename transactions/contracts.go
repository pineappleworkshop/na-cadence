package transactions

import (
	"na-cadence/config"

	"github.com/onflow/flow-go-sdk"
)

func DeployMarketContract(serviceAcctAddr, serviceAcctPrivKey string) (*flow.TransactionResult, error) {
	var contractFilePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		contractFilePath = CLUSTER_FILE_PATH_MARKET_CONTRACT
	} else if config.Conf.GetEnv() == config.TEST {
		contractFilePath = TEST_FILE_PATH_MARKET_CONTRACT
	} else {
		contractFilePath = LOCAL_FILE_PATH_MARKET_CONTRACT
	}

	result, err := DeployContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, MARKET_CONTRACT_NAME)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

func UpdateMarketContract(serviceAcctAddr, serviceAcctPrivKey string) (*flow.TransactionResult, error) {
	var contractFilePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		contractFilePath = CLUSTER_FILE_PATH_MARKET_CONTRACT
	} else if config.Conf.GetEnv() == config.TEST {
		contractFilePath = TEST_FILE_PATH_MARKET_CONTRACT
	} else {
		contractFilePath = LOCAL_FILE_PATH_MARKET_CONTRACT
	}

	result, err := UpdateContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, MARKET_CONTRACT_NAME)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

func DeploySingleContract(serviceAcctAddr, serviceAcctPrivKey string) (*flow.TransactionResult, error) {
	var contractFilePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		contractFilePath = CLUSTER_FILE_PATH_SINGLE_CONTRACT
	} else if config.Conf.GetEnv() == config.TEST {
		contractFilePath = TEST_FILE_PATH_SINGLE_CONTRACT
	} else {
		contractFilePath = LOCAL_FILE_PATH_SINGLE_CONTRACT
	}

	result, err := DeployContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, SINGLE_CONTRACT_NAME)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

func UpdateSingleContract(serviceAcctAddr, serviceAcctPrivKey string) (*flow.TransactionResult, error) {
	var contractFilePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		contractFilePath = CLUSTER_FILE_PATH_SINGLE_CONTRACT
	} else if config.Conf.GetEnv() == config.TEST {
		contractFilePath = TEST_FILE_PATH_SINGLE_CONTRACT
	} else {
		contractFilePath = LOCAL_FILE_PATH_SINGLE_CONTRACT
	}

	result, err := UpdateContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, SINGLE_CONTRACT_NAME)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

func DeployNonFungibleTokenContract(serviceAcctAddr, serviceAcctPrivKey string) (*flow.TransactionResult, error) {
	var contractFilePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		contractFilePath = CLUSTER_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
	} else if config.Conf.GetEnv() == config.TEST {
		contractFilePath = TEST_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
	} else {
		contractFilePath = LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
	}

	result, err := DeployContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

func UpdateNonFungibleTokenContract(serviceAcctAddr, serviceAcctPrivKey string) (*flow.TransactionResult, error) {
	var contractFilePath string
	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
		contractFilePath = CLUSTER_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
	} else if config.Conf.GetEnv() == config.TEST {
		contractFilePath = TEST_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
	} else {
		contractFilePath = LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
	}

	result, err := UpdateContract(serviceAcctAddr, serviceAcctPrivKey, contractFilePath, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
	if err != nil {
		return nil, err
	}
	if result.Error != nil {
		return nil, result.Error
	}

	return result, nil
}

package scripts

// func GetAccountSaleListings(serviceAcctAddr, acctAddr string) ([]*models.SaleListing, error) {
// 	var filePath string
// 	if config.Conf.GetEnv() == config.DEV || config.Conf.GetEnv() == config.PROD {
// 		filePath = CLUSTER_FILE_PATH_READ_ACCOUNT_SALE_LISTINGS
// 	} else {
// 		filePath = LOCAL_FILE_PATH_READ_ACCOUNT_SALE_LISTINGS
// 	}

// 	transactionFile, err := ioutil.ReadFile(filePath)
// 	if err != nil {
// 		return nil, err
// 	}
// 	transactionFileStr := strings.Replace(
// 		string(transactionFile),
// 		SERVICE_ACCOUNT_ADDRESS,
// 		serviceAcctAddr,
// 		-1,
// 	)
// 	transactionFileStr = strings.Replace(
// 		transactionFileStr,
// 		ACCOUNT_ADDRESS,
// 		acctAddr,
// 		-1,
// 	)

// 	scriptResult, err := ExecuteScript([]byte(transactionFileStr))
// 	if err != nil {
// 		return nil, err
// 	}

// 	if scriptResult == nil {
// 		return nil, nil
// 	}

// 	saleListings, err := models.GetSaleListingsByOwnerAddress(acctAddr)
// 	if err != nil {
// 		return nil, err
// 	}

// 	return saleListings, nil
// }

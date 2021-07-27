package handlers

import (
	"fmt"
	"io/ioutil"
	"na-cadence/config"
	"na-cadence/models"
	"net/http"
	"strings"

	"github.com/labstack/echo"
)

func GetScriptByFilename(c echo.Context) error {
	var filePath string
	if config.Conf.GetEnv() == config.WORKSTATION {
		filePath = CADENCE_FILE_PATH_WORKSTATION
	} else if config.Conf.GetEnv() == config.TEST {
		filePath = CADENCE_FILE_PATH_TEST
	} else {
		filePath = CADENCE_FILE_PATH_CLUSTER
	}

	file, err := ioutil.ReadFile(fmt.Sprintf("%s/scripts/%s.cdc", filePath, c.Param("filename")))
	if err != nil {
		c.Logger().Error(err.Error())
		return c.JSON(http.StatusBadRequest, err.Error())
	}
	fileStr := strings.Replace(
		string(file),
		SERVICE_ACCOUNT_ADDRESS,
		config.Conf.FlowServiceAccountAddress,
		-1,
	)
	fileStr = strings.Replace(
		fileStr,
		NON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.NonFungibleTokenContractAddress,
		-1,
	)
	fileStr = strings.Replace(
		fileStr,
		FUNGIBLE_TOKEN_CONTRACT_ADDRESS,
		config.Conf.FungibleTokenContractAddress,
		-1,
	)
	fileStr = strings.Replace(
		fileStr,
		FUSD_CONTRACT_ADDRESS,
		config.Conf.FUSDContractAddress,
		-1,
	)

	resp := new(models.File)
	resp.Name = c.Param("filename")
	resp.Type = FILE_TYPE_SCRIPT
	resp.Data = fileStr

	return c.JSON(http.StatusOK, resp)
}

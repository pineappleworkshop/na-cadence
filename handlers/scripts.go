package handlers

import (
	"fmt"
	"io/ioutil"
	"na-cadence/config"
	"na-cadence/models"
	"net/http"

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

	resp := new(models.File)
	resp.Name = c.Param("filename")
	resp.Type = "script"
	resp.Data = string(file)

	return c.JSON(http.StatusOK, resp)
}

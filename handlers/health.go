package handlers

import (
	"github.com/labstack/echo"
	"na-cadence/config"
	"na-cadence/models"
	"net/http"
)

func HealthHandler(c echo.Context) error {
	health := new(models.Health)
	health.Service = config.SERVICE_NAME
	health.Environment = config.Conf.Env
	health.Status = http.StatusOK
	health.Version = config.VERSION

	return c.JSON(http.StatusOK, health)
}

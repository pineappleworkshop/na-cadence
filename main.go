package main

import (
	"na-cadence/config"
	"na-cadence/handlers"
	"strconv"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func main() {
	config.InitConf()

	e := echo.New()
	e.Use(middleware.CORS())
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	initPrivateRoutes(e)

	go e.Logger.Fatal(e.Start(":" + strconv.Itoa(config.PORT)))
}

func initPrivateRoutes(e *echo.Echo) {
	// health
	e.GET("/health", handlers.HealthHandler)

	// transactions
	e.GET("/transactions/:filename", handlers.GetTransactionByFilename)

	// scripts
	e.GET("/scripts/:filename", handlers.GetScriptByFilename)
}

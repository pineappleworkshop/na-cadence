package models

type Health struct {
	Service     string `json:"service"`
	Environment string `json:"environment"`
	Status      int    `json:"status"`
	Version     string `json:"version"`
}

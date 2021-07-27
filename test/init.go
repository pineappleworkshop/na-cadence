package test

import (
	"flag"
	"testing"
)

// vars to be globally shared by all test files after configuration
var (
	ENV      = WORKSTATION
	BASE_URL = BASE_URL_WORKSTATION

	// todo: declare kvs
)

// init tests env and source proper configurations
func init() {
	var _ = func() bool {
		testing.Init()
		return true
	}()
	env := flag.String("env", "", "environment to point integration test at")
	flag.Parse()
	if env != nil {
		if *env == DEV {
			ENV = DEV
			BASE_URL = BASE_URL_DEV
		}
		if *env == PROD {
			ENV = PROD
			BASE_URL = BASE_URL_PROD
		}
	} // else workstation

	// todo: source kvs and assign to global ^
}

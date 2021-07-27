package scripts

import (
	"na-cadence/config"
	"na-cadence/transactions"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestGetAccount(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: When generating public and private keys", t, func() {
		pubKey, privKey, err := transactions.GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("Then we should be able to create a new account on the flow blockchain", func() {
			acctAddr, err := transactions.CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)

			Convey("Then we should be able to submit a script to get the account", func() {
				acct, err := GetAccount(*acctAddr)
				So(err, ShouldBeNil)
				So(acct, ShouldNotBeNil)
			})
		})
	})
}

func TestGetAccountStatus(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: When generating public and private keys", t, func() {
		pubKey, privKey, err := transactions.GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("Then we should be able to create a new account on the flow blockchain", func() {
			acctAddr, err := transactions.CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)

			Convey("Then we should be able to submit a script to get the account", func() {
				acct, err := GetAccountStatus(config.Conf.FlowServiceAccountAddress, *acctAddr)
				So(err, ShouldBeNil)
				So(acct, ShouldNotBeNil)
			})
		})
	})
}

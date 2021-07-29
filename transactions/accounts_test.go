package transactions

import (
	"na-cadence/config"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestCreateAccount(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: When generating keys", t, func() {
		pubKey, privKey, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("Then we should be able to create a new account on the flow blockchain", func() {
			acctAddr, err := CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)
		})
	})
}

func TestInitializeAccount(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: When generating public and private keys", t, func() {
		pubKey, privKey, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("Then we should be able to create a new account on the flow blockchain", func() {
			acctAddr, err := CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)

			Convey("Then we should be able to submit a transaction to initialize the account", func() {
				txRes, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
				So(err, ShouldBeNil)
				So(txRes, ShouldNotBeNil)
				So(txRes.Error, ShouldBeNil)
			})
		})
	})
}

func TestAuthorizeCreatorAccount(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: When generating public and private keys", t, func() {
		pubKey, privKey, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("Then we should be able to create a new account on the flow blockchain", func() {
			acctAddr, err := CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)

			Convey("Then we should be able to submit a transaction to initialize the account", func() {
				txRes, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
				So(err, ShouldBeNil)
				So(txRes, ShouldNotBeNil)
				So(txRes.Error, ShouldBeNil)

				Convey("Then we should be able to submit a transaction to create the 'creator' resource", func() {
					txRes, err := SetupCreator(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
					So(err, ShouldBeNil)
					So(txRes, ShouldNotBeNil)
					So(txRes.Error, ShouldBeNil)

					Convey("Then we should be able to submit a transaction to deposit the ReleaseCollection capability - authorizing the creator", func() {
						txRes, err := AuthorizeCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddr)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldBeNil)
					})
				})
			})
		})
	})
}

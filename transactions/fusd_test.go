package transactions

import (
	"na-cadence/config"
	"testing"

	"github.com/onflow/cadence"
	. "github.com/smartystreets/goconvey/convey"
)

func TestDepositFUSDIntoAccount(t *testing.T) {
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

				Convey("Then we should be able to submit a transaction to deposit FUSD into the account's vault", func() {
					txRes, err := DepositFUSDIntoAccount(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddr, cadence.UFix64(TEST_FUSD_AMOUNT))
					So(err, ShouldBeNil)
					So(txRes, ShouldNotBeNil)
					So(txRes.Error, ShouldBeNil)
				})
			})
		})
	})
}

package scripts

// import (
// 	"na-cadence/config"
// 	"na-cadence/transactions"
// 	"os"
// 	"testing"

// 	"github.com/onflow/cadence"
// 	. "github.com/smartystreets/goconvey/convey"
// )

// func TestReadFUSDAcctBalance(t *testing.T) {
// 	os.Setenv(config.ENV, config.TEST)
// 	config.InitConf()

// 	Convey("%s: When generating public and private keys", t, func() {
// 		pubKey, privKey, err := transactions.GenerateKeys(config.FLOW_SIG_ALGO_NAME)
// 		So(err, ShouldBeNil)
// 		So(pubKey, ShouldNotBeNil)
// 		So(privKey, ShouldNotBeNil)

// 		Convey("Then we should be able to create a new account on the flow blockchain", func() {
// 			acctAddr, err := transactions.CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
// 			So(err, ShouldBeNil)
// 			So(acctAddr, ShouldNotBeNil)

// 			Convey("Then we should be able to submit a transaction to initialize the account", func() {
// 				txRes, err := transactions.InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
// 				So(err, ShouldBeNil)
// 				So(txRes, ShouldNotBeNil)
// 				So(txRes.Error, ShouldBeNil)

// 				Convey("Then we should be able to submit a transaction to deposit FUSD into the account's vault", func() {
// 					txRes, err := transactions.DepositFUSDIntoAccount(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddr, cadence.UFix64(TEST_FUSD_AMOUNT))
// 					So(err, ShouldBeNil)
// 					So(txRes, ShouldNotBeNil)
// 					So(txRes.Error, ShouldBeNil)

// 					Convey("Then we should be able to submit a script to read the account's FUSD vault's balance", func() {
// 						balance, err := ReadAccountFUSDBalance(config.Conf.FlowServiceAccountAddress, *acctAddr)
// 						So(err, ShouldBeNil)
// 						So(balance, ShouldNotBeNil)
// 					})
// 				})
// 			})
// 		})
// 	})
// }

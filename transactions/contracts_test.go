package transactions

// todo: do we need these? how to disable

// import (
// 	"na-cadence/config"
// 	"testing"

// 	. "github.com/smartystreets/goconvey/convey"
// )

// func TestDeployMarketContract(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When deploying the BlockRecordsMarket contract", t, func() {
// 		txRes, err := DeployMarketContract(config.Conf.FlowServiceAcctAddr, config.Conf.FlowServiceAccountPrivateKey)
// 		So(err, ShouldBeNil)
// 		So(txRes, ShouldNotBeNil)
// 		So(txRes.Error, ShouldBeNil)
// 	})
// }

// func TestUpdateMarketContract(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When updating the BlockRecordsMarket contract", t, func() {
// 		txRes, err := UpdateMarketContract(config.Conf.FlowServiceAcctAddr, config.Conf.FlowServiceAccountPrivateKey)
// 		So(err, ShouldBeNil)
// 		So(txRes, ShouldNotBeNil)
// 		So(txRes.Error, ShouldBeNil)
// 	})
// }

// func TestDeploySingleContract(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When deploying the BlockRecordsSingle contract", t, func() {
// 		txRes, err := DeploySingleContract(config.Conf.FlowServiceAcctAddr, config.Conf.FlowServiceAccountPrivateKey)
// 		So(err, ShouldBeNil)
// 		So(txRes, ShouldNotBeNil)
// 		So(txRes.Error, ShouldBeNil)
// 	})
// }

// func TestUpdateSingleContract(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When updating the BlockRecordsSingle contract", t, func() {
// 		txRes, err := UpdateSingleContract(config.Conf.FlowServiceAcctAddr, config.Conf.FlowServiceAccountPrivateKey)
// 		So(err, ShouldBeNil)
// 		So(txRes, ShouldNotBeNil)
// 		So(txRes.Error, ShouldBeNil)
// 	})
// }

// func TestDeployNonFungibleTokenContract(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When deploying the NonFungibleToken contract", t, func() {
// 		txRes, err := DeployNonFungibleTokenContract(config.Conf.FlowServiceAcctAddr, config.Conf.FlowServiceAccountPrivateKey)
// 		So(err, ShouldBeNil)
// 		So(txRes, ShouldNotBeNil)
// 		So(txRes.Error, ShouldBeNil)
// 	})
// }

// func TestUpdateNonFungibleTokenContract(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When updating the NonFungibleToken contract", t, func() {
// 		txRes, err := UpdateNonFungibleTokenContract(config.Conf.FlowServiceAcctAddr, config.Conf.FlowServiceAccountPrivateKey)
// 		So(err, ShouldBeNil)
// 		So(txRes, ShouldNotBeNil)
// 		So(txRes.Error, ShouldBeNil)
// 	})
// }

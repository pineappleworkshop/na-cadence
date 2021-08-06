package transactions

import (
	"na-cadence/config"
	"testing"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	. "github.com/smartystreets/goconvey/convey"
)

func TestCreatorCreateRelease(t *testing.T) {
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

					Convey("Then we should be able to submit a transaction to deposit the ReleaseCollection capability; authorizing the creator", func() {
						txRes, err := AuthorizeCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddr)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldBeNil)

						Convey("Then we should be able to create a release and deposit it into the release collection", func() {
							royaltyAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
							royaltyFee := 0.05
							release := ReleaseCreate{
								RoyaltyAddress: cadence.Address(royaltyAddress),
								RoyaltyFee:     cadence.UFix64(royaltyFee),
							}
							txRes, err := CreateRelease(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, release)
							So(err, ShouldBeNil)
							So(txRes, ShouldNotBeNil)
							So(txRes.Error, ShouldBeNil)
						})
					})
				})
			})
		})
	})
}

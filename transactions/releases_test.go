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

					Convey("Then we should be able to submit a transaction to deposit the ReleaseCollection capability - authorizing the creator", func() {
						creator := Creator{
							TEST_CREATOR_PROFILE_STAGE_NAME,
							TEST_CREATOR_PROFILE_STAGE_NAME,
							TEST_CREATOR_PROFILE_IMAGE_URL,
							cadence.Address(*acctAddr),
						}
						txRes, err := CreateReleaseCollectionForCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, creator)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldBeNil)

						Convey("Then we should be able to create a release and deposit it into the release collection", func() {
							payoutAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
							payoutPercentFee := TEST_PAYOUT_PERCENT_FEE
							release := ReleaseCreate{
								Type:             cadence.String(TEST_SINGLE_TYPE),
								Name:             cadence.String(TEST_SINGLE_NAME),
								Literation:       cadence.String(TEST_SINGLE_LITERATION),
								ImageURL:         cadence.String(TEST_SINGLE_IMAGE_URL),
								AudioURL:         cadence.String(TEST_SINGLE_AUDIO_URL),
								CopiesCount:      cadence.UInt64(TEST_SINGLE_COPIES_COUNT),
								PayoutAddress:    cadence.Address(payoutAddress),
								PayoutPercentFee: cadence.UFix64(payoutPercentFee),
								ReceiverAddress:  cadence.Address(*acctAddr),
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

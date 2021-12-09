package transactions

import (
	"na-cadence/config"
	"os"
	"testing"

	"github.com/onflow/cadence"
	. "github.com/smartystreets/goconvey/convey"
)

func TestCreatorCreateRelease(t *testing.T) {
	os.Setenv(config.ENV, config.TEST)
	config.InitConf()

	Convey("%s: generate public and private keys", t, func() {
		pubKey, privKey, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("create a new account on the flow blockchain", func() {
			acctAddr, err := CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)

			Convey("initialize the new account", func() {
				txRes, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
				So(err, ShouldBeNil)
				So(txRes, ShouldNotBeNil)
				So(txRes.Error, ShouldBeNil)

				Convey("service account should be able to create a new release collection for a creator and give them and the marketplace capabilities to it", func() {
					rc := ReleaseCollection{
						Name:           "",
						Description:    "",
						Logo:           "",
						Banner:         "",
						Website:        "",
						SocialMedias:   cadence.Array{},
						CreatorAddress: cadence.Address(*acctAddr),
					}
					txRes, err := CreateReleaseCollectionForCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, rc)
					So(err, ShouldBeNil)
					So(txRes, ShouldNotBeNil)
					So(txRes.Error, ShouldBeNil)

					Convey("creator should be able to create a release collection", func() {
						// payoutAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
						// payoutPercentFee := TEST_PAYOUT_PERCENT_FEE
						release := ReleaseCreate{
							Type:              cadence.String(TEST_SINGLE_TYPE),
							Name:              cadence.String(TEST_SINGLE_NAME),
							Literation:        cadence.String(TEST_SINGLE_LITERATION),
							Image:             cadence.String(TEST_SINGLE_IMAGE_URL),
							Audio:             cadence.String(TEST_SINGLE_AUDIO_URL),
							CopiesCount:       cadence.NewInt(TEST_SINGLE_COPIES_COUNT),
							PayoutAddresses:   cadence.Array{},
							PayoutPercentFees: cadence.Array{},
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
}

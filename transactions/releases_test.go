package transactions

import (
	"na-cadence/config"
	"testing"

	"github.com/onflow/cadence"
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

						Convey("Then we should be able to mint an nft and deposit it into the account's collection", func() {
							nft := NFTCreate{
								Name:                   TEST_SINGLE_NAME,
								ReceiverAccountAddress: cadence.Address(*acctAddr),
								RoyaltyAddress:         cadence.Address(*acctAddr),
								RoyaltyPercentage:      cadence.UInt64(TEST_SINGLE_ROYALTY_PERCENTAGE),
								Type:                   TEST_SINGLE_TYPE,
								Literation:             TEST_SINGLE_LITERATION,
								AudioURL:               TEST_SINGLE_AUDIO_URL,
								ImageURL:               TEST_SINGLE_IMAGE_URL,
							}
							txRes, err := MintSingle(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, nft)
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

func TestNonCreatorMintSingle(t *testing.T) {
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

					Convey("Then we should not be able to mint an nft because we haven't been authorized", func() {
						nft := NFTCreate{
							Name:                   TEST_SINGLE_NAME,
							ReceiverAccountAddress: cadence.Address(*acctAddr),
							RoyaltyAddress:         cadence.Address(*acctAddr),
							RoyaltyPercentage:      cadence.UInt64(TEST_SINGLE_ROYALTY_PERCENTAGE),
							Type:                   TEST_SINGLE_TYPE,
							Literation:             TEST_SINGLE_LITERATION,
							AudioURL:               TEST_SINGLE_AUDIO_URL,
							ImageURL:               TEST_SINGLE_IMAGE_URL,
						}
						txRes, err := MintSingle(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, nft)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldNotBeNil)
					})
				})
			})
		})
	})
}
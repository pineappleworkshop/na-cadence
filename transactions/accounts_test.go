package transactions

import (
	"na-cadence/config"
	"testing"

	"github.com/onflow/cadence"
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

func TestCreateReleaseCollectionForNewCreator(t *testing.T) {
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
							"robbie wasabi",
							"Robert Rossilli",
							"https://ipfs.io/ipfs/Qmc4EA9rNdHVDKQUDWDgeGyL7pL1FDFMkT2ZnWC61DvaQd",
							cadence.Address(*acctAddr),
						}
						txRes, err := CreateReleaseCollectionForCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, creator)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldBeNil)
					})
				})
			})
		})
	})
}

// func TestUnlinkReleaseCollectionFromCreator(t *testing.T) {
// 	config.InitConf()
// 	config.Conf.Env = config.TEST

// 	Convey("%s: When generating public and private keys", t, func() {
// 		pubKey, privKey, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
// 		So(err, ShouldBeNil)
// 		So(pubKey, ShouldNotBeNil)
// 		So(privKey, ShouldNotBeNil)

// 		Convey("Then we should be able to create a new account on the flow blockchain", func() {
// 			acctAddr, err := CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
// 			So(err, ShouldBeNil)
// 			So(acctAddr, ShouldNotBeNil)

// 			Convey("Then we should be able to submit a transaction to initialize the account", func() {
// 				txRes, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
// 				So(err, ShouldBeNil)
// 				So(txRes, ShouldNotBeNil)
// 				So(txRes.Error, ShouldBeNil)

// 				Convey("Then we should be able to submit a transaction to create the 'creator' resource", func() {
// 					txRes, err := SetupCreator(config.Conf.FlowServiceAccountAddress, *acctAddr, privKey)
// 					So(err, ShouldBeNil)
// 					So(txRes, ShouldNotBeNil)
// 					So(txRes.Error, ShouldBeNil)

// 					Convey("Then we should be able to submit a transaction to deposit the ReleaseCollection capability - authorizing the creator", func() {
// 						creator := Creator{
// 							"robbie wasabi",
// 							"Robert Rossilli",
// 							"https://ipfs.io/ipfs/Qmc4EA9rNdHVDKQUDWDgeGyL7pL1FDFMkT2ZnWC61DvaQd",
// 							cadence.Address(*acctAddr),
// 						}
// 						txRes, err := CreateReleaseCollectionForCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, creator)
// 						So(err, ShouldBeNil)
// 						So(txRes, ShouldNotBeNil)
// 						So(txRes.Error, ShouldBeNil)

// 						Convey("Then we should be able to submit a transaction to unlink the creator's capability from the service account - deauthorizing the creator", func() {
// 							txRes, err := DeauthorizeCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddr)
// 							So(err, ShouldBeNil)
// 							So(txRes, ShouldNotBeNil)
// 							So(txRes.Error, ShouldBeNil)

// 							Convey("Then we should not be able to mint an nft because we haven't been authorized", func() {
// 								nft := NFTCreate{
// 									Name:        TEST_SINGLE_NAME,
// 									Type:        TEST_SINGLE_TYPE,
// 									Literation:  TEST_SINGLE_LITERATION,
// 									AudioURL:    TEST_SINGLE_AUDIO_URL,
// 									ImageURL:    TEST_SINGLE_IMAGE_URL,
// 									CopiesCount: cadence.NewInt(1),
// 									ReleaseID:   cadence.UInt64(1),
// 								}
// 								txRes, err := mint(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, nft)
// 								So(err, ShouldBeNil)
// 								So(txRes, ShouldNotBeNil)
// 								So(txRes.Error, ShouldNotBeNil)
// 							})
// 						})
// 					})
// 				})
// 			})
// 		})
// 	})
// }

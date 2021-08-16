package transactions

import (
	"encoding/json"
	"na-cadence/config"
	"strconv"
	"strings"
	"testing"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	. "github.com/smartystreets/goconvey/convey"
)

func TestCreateSaleListing(t *testing.T) {
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

						Convey("Then we should be able to create a release and deposit it into the release collection", func() {
							payoutAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
							payoutPercentFee := 0.05
							release := ReleaseCreate{
								Name:             cadence.String("flowin'"),
								Description:      cadence.String("debut release"),
								Type:             cadence.String("single"),
								PayoutAddress:    cadence.Address(payoutAddress),
								PayoutPercentFee: cadence.UFix64(payoutPercentFee),
							}
							txRes, err := CreateRelease(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, release)
							So(err, ShouldBeNil)
							So(txRes, ShouldNotBeNil)
							So(txRes.Error, ShouldBeNil)

							var releaseID cadence.UInt64
							for _, e := range txRes.Events {
								fieldName := e.Value.Fields[0].String()
								if strings.Contains(fieldName, "release_created") {
									value := e.Value.Fields[1].String()
									body := make(map[string]string)
									_ = json.Unmarshal([]byte(value), &body)
									u64, _ := strconv.ParseUint(body["id"], 10, 64)
									releaseID = cadence.UInt64(u64)
									break
								}
							}

							So(releaseID, ShouldNotBeNil)

							Convey("Then we should be able to mint an nft and deposit it into the account's collection", func() {
								nft := NFTCreate{
									Name:        TEST_SINGLE_NAME,
									Type:        TEST_SINGLE_TYPE,
									Literation:  TEST_SINGLE_LITERATION,
									AudioURL:    TEST_SINGLE_AUDIO_URL,
									ImageURL:    TEST_SINGLE_IMAGE_URL,
									CopiesCount: cadence.NewInt(1),
									ReleaseID:   releaseID,
								}
								txRes, err := MintSingle(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, nft)
								So(err, ShouldBeNil)
								So(txRes, ShouldNotBeNil)
								So(txRes.Error, ShouldBeNil)

								var nftID cadence.UInt64
								for _, e := range txRes.Events {
									fieldName := e.Value.Fields[0].String()
									if strings.Contains(fieldName, "minted") {
										value := e.Value.Fields[1].String()
										body := make(map[string]string)
										_ = json.Unmarshal([]byte(value), &body)
										u64, _ := strconv.ParseUint(body["id"], 10, 64)
										nftID = cadence.UInt64(u64)
										break
									}
								}
								So(nftID, ShouldNotBeNil)

								Convey("Then we should be able to create a sale listing for the new nft", func() {
									saleListing := SaleListingCreate{
										ID:    nftID,
										Price: cadence.UFix64(100),
									}
									txRes, err := CreateSaleListing(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, saleListing)
									So(err, ShouldBeNil)
									So(txRes, ShouldNotBeNil)
									So(txRes.Error, ShouldBeNil)
								})
							})
						})
					})
				})
			})
		})
	})
}

func TestDestroySaleListing(t *testing.T) {
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

						Convey("Then we should be able to create a release and deposit it into the release collection", func() {
							payoutAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
							payoutPercentFee := 0.05
							release := ReleaseCreate{
								Name:             cadence.String("flowin'"),
								Description:      cadence.String("debut release"),
								Type:             cadence.String("single"),
								PayoutAddress:    cadence.Address(payoutAddress),
								PayoutPercentFee: cadence.UFix64(payoutPercentFee),
							}
							txRes, err := CreateRelease(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, release)
							So(err, ShouldBeNil)
							So(txRes, ShouldNotBeNil)
							So(txRes.Error, ShouldBeNil)

							var releaseID cadence.UInt64
							for _, e := range txRes.Events {
								fieldName := e.Value.Fields[0].String()
								if strings.Contains(fieldName, "release_created") {
									value := e.Value.Fields[1].String()
									body := make(map[string]string)
									_ = json.Unmarshal([]byte(value), &body)
									u64, _ := strconv.ParseUint(body["id"], 10, 64)
									releaseID = cadence.UInt64(u64)
									break
								}
							}

							So(releaseID, ShouldNotBeNil)

							Convey("Then we should be able to mint an nft and deposit it into the account's collection", func() {
								nft := NFTCreate{
									Name:        TEST_SINGLE_NAME,
									Type:        TEST_SINGLE_TYPE,
									Literation:  TEST_SINGLE_LITERATION,
									AudioURL:    TEST_SINGLE_AUDIO_URL,
									ImageURL:    TEST_SINGLE_IMAGE_URL,
									CopiesCount: cadence.NewInt(1),
									ReleaseID:   cadence.UInt64(1),
								}
								txRes, err := MintSingle(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, nft)
								So(err, ShouldBeNil)
								So(txRes, ShouldNotBeNil)
								So(txRes.Error, ShouldBeNil)

								var nftID cadence.UInt64
								for _, e := range txRes.Events {
									fieldName := e.Value.Fields[0].String()
									if strings.Contains(fieldName, "minted") {
										value := e.Value.Fields[1].String()
										body := make(map[string]string)
										_ = json.Unmarshal([]byte(value), &body)
										u64, _ := strconv.ParseUint(body["id"], 10, 64)
										nftID = cadence.UInt64(u64)
										break
									}
								}
								So(nftID, ShouldNotBeNil)

								Convey("Then we should be able to create a sale listing for the new nft", func() {
									saleListing := SaleListingCreate{
										ID:    nftID,
										Price: cadence.UFix64(100),
									}

									txRes, err := CreateSaleListing(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, saleListing)
									So(err, ShouldBeNil)
									So(txRes, ShouldNotBeNil)
									So(txRes.Error, ShouldBeNil)

									var listingID cadence.UInt64
									for _, e := range txRes.Events {
										fieldName := e.Value.Fields[0].String()
										if strings.Contains(fieldName, "sale_listing_for_sale") {
											value := e.Value.Fields[1].String()
											body := make(map[string]string)
											_ = json.Unmarshal([]byte(value), &body)
											u64, _ := strconv.ParseUint(body["id"], 10, 64)
											listingID = cadence.UInt64(u64)
											break
										}
									}
									So(listingID, ShouldNotBeNil)

									Convey("Then we should be able to destroy the new sale listing", func() {
										txRes, err := DestroySaleListing(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, listingID)
										So(err, ShouldBeNil)
										So(txRes, ShouldNotBeNil)
										So(txRes.Error, ShouldBeNil)
									})
								})
							})
						})
					})
				})
			})
		})
	})
}

func TestBuySaleListing(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: When generating public and private keys for a buyer and a seller", t, func() {
		pubKeyBuyer, privKeyBuyer, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKeyBuyer, ShouldNotBeNil)
		So(privKeyBuyer, ShouldNotBeNil)

		pubKeySeller, privKeySeller, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKeySeller, ShouldNotBeNil)
		So(privKeySeller, ShouldNotBeNil)

		Convey("Then we should be able to create two new accounts on the flow blockchain", func() {
			acctAddrBuyer, err := CreateAccount(config.Conf.FlowAccessNode, &pubKeyBuyer, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddrBuyer, ShouldNotBeNil)

			acctAddrSeller, err := CreateAccount(config.Conf.FlowAccessNode, &pubKeySeller, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddrSeller, ShouldNotBeNil)

			Convey("Then we should be able to submit transactions to initialize both accounts", func() {
				txResBuyer, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddrBuyer, privKeyBuyer)
				So(err, ShouldBeNil)
				So(txResBuyer, ShouldNotBeNil)
				So(txResBuyer.Error, ShouldBeNil)

				txResSeller, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddrSeller, privKeySeller)
				So(err, ShouldBeNil)
				So(txResSeller, ShouldNotBeNil)
				So(txResSeller.Error, ShouldBeNil)

				Convey("Then we should be able to submit a transaction to create the 'creator' resource", func() {
					txRes, err := SetupCreator(config.Conf.FlowServiceAccountAddress, *acctAddrSeller, privKeySeller)
					So(err, ShouldBeNil)
					So(txRes, ShouldNotBeNil)
					So(txRes.Error, ShouldBeNil)

					Convey("Then we should be able to submit a transaction to deposit the ReleaseCollection capability - authorizing the creator", func() {
						creator := Creator{
							"robbie wasabi",
							"Robert Rossilli",
							"https://ipfs.io/ipfs/Qmc4EA9rNdHVDKQUDWDgeGyL7pL1FDFMkT2ZnWC61DvaQd",
							cadence.Address(*acctAddrSeller),
						}
						txRes, err := CreateReleaseCollectionForCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, creator)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldBeNil)

						Convey("Then we should be able to create a release and deposit it into the release collection", func() {
							payoutAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
							payoutPercentFee := 0.05
							release := ReleaseCreate{
								Name:             cadence.String("flowin'"),
								Description:      cadence.String("my debut release"),
								Type:             cadence.String("single"),
								PayoutAddress:    cadence.Address(payoutAddress),
								PayoutPercentFee: cadence.UFix64(payoutPercentFee),
							}
							txRes, err := CreateRelease(config.Conf.FlowServiceAccountAddress, acctAddrSeller.String(), privKeySeller, release)
							So(err, ShouldBeNil)
							So(txRes, ShouldNotBeNil)
							So(txRes.Error, ShouldBeNil)

							var releaseID cadence.UInt64
							for _, e := range txRes.Events {
								fieldName := e.Value.Fields[0].String()
								if strings.Contains(fieldName, "release_created") {
									value := e.Value.Fields[1].String()
									body := make(map[string]string)
									_ = json.Unmarshal([]byte(value), &body)
									u64, _ := strconv.ParseUint(body["id"], 10, 64)
									releaseID = cadence.UInt64(u64)
									break
								}
							}

							So(releaseID, ShouldNotBeNil)

							Convey("Then we should be able to mint an nft and deposit it into the seller account's collection", func() {
								nft := NFTCreate{
									Name:        TEST_SINGLE_NAME,
									Type:        TEST_SINGLE_TYPE,
									Literation:  TEST_SINGLE_LITERATION,
									AudioURL:    TEST_SINGLE_AUDIO_URL,
									ImageURL:    TEST_SINGLE_IMAGE_URL,
									CopiesCount: cadence.NewInt(1),
									ReleaseID:   cadence.UInt64(releaseID),
								}
								txRes, err := MintSingle(config.Conf.FlowServiceAccountAddress, acctAddrSeller.String(), privKeySeller, nft)
								So(err, ShouldBeNil)
								So(txRes, ShouldNotBeNil)
								So(txRes.Error, ShouldBeNil)

								var nftID cadence.UInt64
								for _, e := range txRes.Events {
									fieldName := e.Value.Fields[0].String()
									if strings.Contains(fieldName, "minted") {
										value := e.Value.Fields[1].String()
										body := make(map[string]string)
										_ = json.Unmarshal([]byte(value), &body)
										u64, _ := strconv.ParseUint(body["id"], 10, 64)
										nftID = cadence.UInt64(u64)
										break
									}
								}
								So(nftID, ShouldNotBeNil)

								Convey("Then we should be able to create a sale listing for the new nft", func() {
									saleListing := SaleListingCreate{
										ID:    nftID,
										Price: cadence.UFix64(100),
									}
									txRes, err := CreateSaleListing(config.Conf.FlowServiceAccountAddress, acctAddrSeller.String(), privKeySeller, saleListing)
									So(err, ShouldBeNil)
									So(txRes, ShouldNotBeNil)
									So(txRes.Error, ShouldBeNil)

									var listingID cadence.UInt64
									for _, e := range txRes.Events {
										fieldName := e.Value.Fields[0].String()
										if strings.Contains(fieldName, "sale_listing_for_sale") {
											value := e.Value.Fields[1].String()
											body := make(map[string]string)
											_ = json.Unmarshal([]byte(value), &body)
											u64, _ := strconv.ParseUint(body["id"], 10, 64)
											listingID = cadence.UInt64(u64)
											break
										}
									}
									So(listingID, ShouldNotBeNil)

									Convey("Then we should be able to submit a transaction to deposit FUSD into buyer account's vault", func() {
										txRes, err := DepositFUSDIntoAccount(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddrBuyer, cadence.UFix64(TEST_FUSD_AMOUNT))
										So(err, ShouldBeNil)
										So(txRes, ShouldNotBeNil)
										So(txRes.Error, ShouldBeNil)

										Convey("Then the buyer should be able to purchase the nft for FUSD and deposit it into their collection", func() {
											txRes, err := BuySaleListing(config.Conf.FlowServiceAccountAddress, acctAddrBuyer.String(), privKeyBuyer, listingID, cadence.Address(*acctAddrSeller))
											So(err, ShouldBeNil)
											So(txRes, ShouldNotBeNil)
											So(txRes.Error, ShouldBeNil)
										})
									})
								})
							})
						})
					})
				})
			})
		})
	})
}

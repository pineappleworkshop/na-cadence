package transactions

import (
	"na-cadence/config"
	"na-cadence/scripts"
	"strconv"
	"testing"

	"github.com/onflow/cadence"
	. "github.com/smartystreets/goconvey/convey"
)

func TestCreateSaleListing(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: generate public and private keys", t, func() {
		pubKey, privKey, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKey, ShouldNotBeNil)
		So(privKey, ShouldNotBeNil)

		Convey("create a new account on the flow blockchain ", func() {
			acctAddr, err := CreateAccount(config.Conf.FlowAccessNode, &pubKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddr, ShouldNotBeNil)
			Printf("new account address: %v", acctAddr)

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

						// get the id of the last nft minted
						var nftID cadence.UInt64
						for _, e := range txRes.Events {
							if e.Type == "A."+config.Conf.FlowServiceAccountAddress+".BlockRecordsSingle.Minted" {
								val := e.Value.Fields[0].String()
								u64, _ := strconv.ParseUint(val, 10, 64)
								nftID = cadence.UInt64(u64)
							}
							if e.Type == "A."+config.Conf.FlowServiceAccountAddress+".BlockRecordsSingle.Deposit" {
								Println()
								Printf("deposit: %v", e.Value.Fields)
							}
						}
						So(nftID, ShouldNotBeNil)

						Convey("nfts should exist in creator collection", func() {
							singles, err := scripts.GetSinglesByAccountAddress(config.Conf.FlowServiceAccountAddress, "0x"+acctAddr.String())
							if err != nil {
								Println()
								Print(err)
							}
							So(err, ShouldBeNil)
							So(singles, ShouldNotBeNil)
							Println()
							Printf("minted singles: %v", singles)
							So(txRes.Error, ShouldBeNil)

							Convey("creator should be able to create a listing for their nft", func() {
								saleListing := SaleListingCreate{
									NFTID: nftID,
									Price: cadence.UFix64(TEST_SALE_LISTING_PRICE),
								}
								Println()
								Printf("creating listing for nft id: %v", saleListing.NFTID)
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
}

func TestBuySaleListing(t *testing.T) {
	config.InitConf()
	config.Conf.Env = config.TEST

	Convey("%s: generate public and private keys  ", t, func() {
		pubKeyBuyer, privKeyBuyer, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKeyBuyer, ShouldNotBeNil)
		So(privKeyBuyer, ShouldNotBeNil)

		pubKeySeller, privKeySeller, err := GenerateKeys(config.FLOW_SIG_ALGO_NAME)
		So(err, ShouldBeNil)
		So(pubKeySeller, ShouldNotBeNil)
		So(privKeySeller, ShouldNotBeNil)

		Convey("create new accounts on the flow blockchain", func() {
			acctAddrBuyer, err := CreateAccount(config.Conf.FlowAccessNode, &pubKeyBuyer, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddrBuyer, ShouldNotBeNil)

			acctAddrSeller, err := CreateAccount(config.Conf.FlowAccessNode, &pubKeySeller, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_HASH_ALGO_NAME, nil, config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, config.FLOW_SERVICE_ACCOUNT_SIG_ALG, config.FLOW_GAS_LIMIT)
			So(err, ShouldBeNil)
			So(acctAddrSeller, ShouldNotBeNil)

			Convey("initialize the new accounts", func() {
				txResBuyer, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddrBuyer, privKeyBuyer)
				So(err, ShouldBeNil)
				So(txResBuyer, ShouldNotBeNil)
				So(txResBuyer.Error, ShouldBeNil)

				txResSeller, err := InitializeAccount(config.Conf.FlowServiceAccountAddress, *acctAddrSeller, privKeySeller)
				So(err, ShouldBeNil)
				So(txResSeller, ShouldNotBeNil)
				So(txResSeller.Error, ShouldBeNil)

				Convey("service account should be able to create a new release collection for a creator and give them and the marketplace capabilities to it", func() {
					rc := ReleaseCollection{
						Name:           "",
						Description:    "",
						Logo:           "",
						Banner:         "",
						Website:        "",
						SocialMedias:   cadence.Array{},
						CreatorAddress: cadence.Address(*acctAddrSeller),
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
						txRes, err := CreateRelease(config.Conf.FlowServiceAccountAddress, acctAddrSeller.String(), privKeySeller, release)
						So(err, ShouldBeNil)
						So(txRes, ShouldNotBeNil)
						So(txRes.Error, ShouldBeNil)

						// get the id of the last nft minted
						var nftID cadence.UInt64
						for _, e := range txRes.Events {
							if e.Type == "A."+config.Conf.FlowServiceAccountAddress+".BlockRecordsSingle.Minted" {
								val := e.Value.Fields[0].String()
								u64, _ := strconv.ParseUint(val, 10, 64)
								nftID = cadence.UInt64(u64)
							}
						}
						So(nftID, ShouldNotBeNil)

						Convey("nfts should exist in creator collection", func() {
							singles, err := scripts.GetSinglesByAccountAddress(config.Conf.FlowServiceAccountAddress, "0x"+acctAddrSeller.String())
							if err != nil {
								Println()
								Print(err)
							}
							So(err, ShouldBeNil)
							So(singles, ShouldNotBeNil)
							Println()
							Printf("minted singles: %v", singles)
							So(txRes.Error, ShouldBeNil)

							Convey("creator should be able to create a listing for their nft", func() {
								saleListing := SaleListingCreate{
									NFTID: nftID,
									Price: cadence.UFix64(TEST_SALE_LISTING_PRICE),
								}
								Println()
								Printf("creating listing for nft id: %v", saleListing.NFTID)
								txRes, err := CreateSaleListing(config.Conf.FlowServiceAccountAddress, acctAddrSeller.String(), privKeySeller, saleListing)
								So(err, ShouldBeNil)
								So(txRes, ShouldNotBeNil)
								So(txRes.Error, ShouldBeNil)

								var listingID cadence.UInt64
								for _, e := range txRes.Events {
									if e.Type == "A."+config.Conf.FlowServiceAccountAddress+".BlockRecordsStorefront.ListingAvailable" {
										val := e.Value.Fields[1].String()
										u64, _ := strconv.ParseUint(val, 10, 64)
										listingID = cadence.UInt64(u64)
									}
								}
								So(listingID, ShouldNotBeNil)

								Convey("deposit FUSD into buyer account's vault", func() {
									txRes, err := DepositFUSDIntoAccount(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, *acctAddrBuyer, cadence.UFix64(TEST_FUSD_AMOUNT))
									So(err, ShouldBeNil)
									So(txRes, ShouldNotBeNil)
									So(txRes.Error, ShouldBeNil)

									Convey("buyer should be able to purchase the nft for FUSD and deposit it into their collection", func() {
										txRes, err := BuySaleListing(config.Conf.FlowServiceAccountAddress, acctAddrBuyer.String(), privKeyBuyer, listingID, cadence.Address(*acctAddrSeller))
										So(err, ShouldBeNil)
										So(txRes, ShouldNotBeNil)
										So(txRes.Error, ShouldBeNil)

										Convey("an nft should exist in buyer collection", func() {
											singles, err := scripts.GetSinglesByAccountAddress(config.Conf.FlowServiceAccountAddress, "0x"+acctAddrBuyer.String())
											if err != nil {
												Println()
												Print(err)
											}
											So(err, ShouldBeNil)
											So(singles, ShouldNotBeNil)
											Println()
											Printf("%v", singles)
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

// func TestDestroySaleListing(t *testing.T) {
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
// 							TEST_CREATOR_PROFILE_STAGE_NAME,
// 							TEST_CREATOR_PROFILE_STAGE_NAME,
// 							TEST_CREATOR_PROFILE_IMAGE_URL,
// 							cadence.Address(*acctAddr),
// 						}
// 						txRes, err := CreateReleaseCollectionForCreator(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, creator)
// 						So(err, ShouldBeNil)
// 						So(txRes, ShouldNotBeNil)
// 						So(txRes.Error, ShouldBeNil)

// 						Convey("Then we should be able to create a release and deposit it into the release collection", func() {
// 							payoutAddress := flow.HexToAddress(config.Conf.FlowServiceAccountAddress)
// 							payoutPercentFee := TEST_PAYOUT_PERCENT_FEE
// 							release := ReleaseCreate{
// 								Type:             cadence.String(TEST_SINGLE_TYPE),
// 								Name:             cadence.String(TEST_SINGLE_NAME),
// 								Literation:       cadence.String(TEST_SINGLE_LITERATION),
// 								ImageURL:         cadence.String(TEST_SINGLE_IMAGE_URL),
// 								AudioURL:         cadence.String(TEST_SINGLE_AUDIO_URL),
// 								CopiesCount:      cadence.UInt64(TEST_SINGLE_COPIES_COUNT),
// 								PayoutAddress:    cadence.Address(payoutAddress),
// 								PayoutPercentFee: cadence.UFix64(payoutPercentFee),
// 								ReceiverAddress:  cadence.Address(*acctAddr),
// 							}
// 							txRes, err := CreateRelease(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, release)
// 							So(err, ShouldBeNil)
// 							So(txRes, ShouldNotBeNil)
// 							So(txRes.Error, ShouldBeNil)

// 							var nftID cadence.UInt64
// 							for _, e := range txRes.Events {
// 								fieldName := e.Value.Fields[0].String()
// 								if strings.Contains(fieldName, "minted") {
// 									value := e.Value.Fields[1].String()
// 									body := make(map[string]string)
// 									_ = json.Unmarshal([]byte(value), &body)
// 									u64, _ := strconv.ParseUint(body["id"], 10, 64)
// 									nftID = cadence.UInt64(u64)
// 									break
// 								}
// 							}
// 							So(nftID, ShouldNotBeNil)

// 							Convey("Then we should be able to create a sale listing for the new nft", func() {
// 								saleListing := SaleListingCreate{
// 									ID:    nftID,
// 									Price: cadence.UFix64(TEST_SALE_LISTING_PRICE),
// 								}
// 								txRes, err := CreateSaleListing(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, saleListing)
// 								So(err, ShouldBeNil)
// 								So(txRes, ShouldNotBeNil)
// 								So(txRes.Error, ShouldBeNil)

// 								var listingID cadence.UInt64
// 								for _, e := range txRes.Events {
// 									fieldName := e.Value.Fields[0].String()
// 									if strings.Contains(fieldName, "sale_listing_for_sale") {
// 										value := e.Value.Fields[1].String()
// 										body := make(map[string]string)
// 										_ = json.Unmarshal([]byte(value), &body)
// 										u64, _ := strconv.ParseUint(body["id"], 10, 64)
// 										listingID = cadence.UInt64(u64)
// 										break
// 									}
// 								}
// 								So(listingID, ShouldNotBeNil)

// 								Convey("Then we should be able to destroy the new sale listing", func() {
// 									txRes, err := DestroySaleListing(config.Conf.FlowServiceAccountAddress, acctAddr.String(), privKey, listingID)
// 									So(err, ShouldBeNil)
// 									So(txRes, ShouldNotBeNil)
// 									So(txRes.Error, ShouldBeNil)
// 								})
// 							})
// 						})
// 					})
// 				})
// 			})
// 		})
// 	})
// }

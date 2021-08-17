
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

pub contract BlockRecordsMarketplace {

	//events
	//
	pub event ContractInitialized()
	pub event Event(type: String, metadata: {String: String})

	// named paths
	//
	pub let MarketplaceStoragePath: StoragePath
	pub let MarketplacePublicPath: PublicPath
	pub let MarketplacePrivatePath: PrivatePath

	pub let AdminPrivatePath: PrivatePath
	pub let AdminStoragePath: StoragePath

	pub resource interface MarketplacePublic {
		pub let name: String
		pub let payout: Payout
		pub fun borrowReleaseCollections(): [&ReleaseCollection]
		pub fun borrowReleaseCollectionByProfileAddress(_ address: Address): &ReleaseCollection
		pub fun borrowReleaseByNFTID(_ nftID: UInt64): &Release
	}

	// any account in posession of a Marketplace capability will be able to create release collections
	// 
	pub resource Marketplace: MarketplacePublic {  

		// name of the marketplace
		pub let name: String

		// the sale fee cut of the marketplace
		pub let payout: Payout

		// todo: change this to dict
		access(account) var releaseCollectionCapabilities: [Capability<&ReleaseCollection>]

		init(
			name: String,
			fusdVault: Capability<&{FungibleToken.Receiver}>,
			percentFee: UFix64
		){
			self.name = name

			self.payout = Payout(
				fusdVault: fusdVault,
				percentFee: percentFee
			)

			self.releaseCollectionCapabilities = []
		}

		pub fun addReleaseCollectionCapability(cap: Capability<&ReleaseCollection>) {
			self.releaseCollectionCapabilities.append(cap)
		}

		pub fun borrowReleaseCollections(): [&ReleaseCollection] {
			let releaseCollections: [&ReleaseCollection] = []
			for rc in self.releaseCollectionCapabilities {
				let releaseCollection = rc!.borrow()!
				releaseCollections.append(releaseCollection)
			}
			return releaseCollections as [&ReleaseCollection]
		}

		// borrow release collection by creator profile address
		pub fun borrowReleaseCollectionByProfileAddress(_ address: Address) : &ReleaseCollection {
			var releaseCollection: &ReleaseCollection? = nil
			let releaseCollections = self.borrowReleaseCollections()
			for rc in releaseCollections {
				if rc.creatorProfile.address == address {
					releaseCollection = rc as &ReleaseCollection
					break
				}
			}
			return releaseCollection! as &ReleaseCollection
		}

		// borrow release by nft id
		pub fun borrowReleaseByNFTID(_ nftID: UInt64) : &Release {
			var releaseCollection: &ReleaseCollection? = nil
			var release: &Release? = nil
			let releaseCollections = self.borrowReleaseCollections()
			for rc in releaseCollections {
				for key in rc.releases.keys {
					let r: &Release = &rc.releases[key] as &Release
					if r.nftIDs.contains(nftID) {
						release = r as &Release
						break
					}
				}
			}
			return release! as &Release
		}
	}

	pub resource interface AdminPublic {
			pub fun addCapability(cap: Capability<&Marketplace>)
	}

	// accounts can create creator resource but will need to be authorized
	pub fun createAdmin(): @Admin {
			return <- create Admin()
	}

	// resource that an admin would own to be able to create Release Collections
	// 
	pub resource Admin: AdminPublic {

			//ownership of this capability allows for the creation of Release Collections
			access(account) var marketplaceCapability: Capability<&Marketplace>?

			init() {
				self.marketplaceCapability = nil
			}

			pub fun addCapability(cap: Capability<&Marketplace>) {
				pre {
						cap.check() : "invalid capability"
						self.marketplaceCapability == nil : "capability already set"
				}
				self.marketplaceCapability = cap
			}

			// create release collection
			pub fun createReleaseCollection(
				creatorStageName: String,
				creatorLegalName: String,
				creatorImageURL: String,
				creatorAddress: Address
			): @ReleaseCollection {
				return <- create ReleaseCollection(
					creatorStageName: creatorStageName,
					creatorLegalName: creatorLegalName,
					creatorImageURL: creatorImageURL,
					creatorAddress: creatorAddress
				)
			}
	}

	init() {
			self.MarketplaceStoragePath = /storage/BlockRecordsMarketplace002
			self.MarketplacePublicPath = /public/BlockRecordsMarketplace002
			self.MarketplacePrivatePath = /private/BlockRecordsMarketplace002
			
			self.AdminPrivatePath = /private/BlockRecordsAdmin002
			self.AdminStoragePath = /storage/BlockRecordsAdmin002

			// initialize FUSD vault for service account so that we can receive sale percentFees and check balance
			self.account.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
			self.account.link<&FUSD.Vault{FungibleToken.Receiver}>(
				/public/fusdReceiver,
				target: /storage/fusdVault
			)
			self.account.link<&FUSD.Vault{FungibleToken.Balance}>(
				/public/fusdBalance,
				target: /storage/fusdVault
			)

			// initialize and save marketplace resource to account storage
			let marketplaceFUSDVault = self.account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
			let marketplace <- create Marketplace(
				name: "Block Records",
				fusdVault: marketplaceFUSDVault,
				percentFee: 0.05
			)
			self.account.save(<- marketplace, to: self.MarketplaceStoragePath)
			self.account.link<&BlockRecordsSingle.Marketplace>(
				self.MarketplacePrivatePath,
				target: self.MarketplaceStoragePath
			)

			// todo: store public interface private?
			self.account.link<&BlockRecordsSingle.Marketplace{BlockRecordsSingle.MarketplacePublic}>(
				self.MarketplacePublicPath,
				target: self.MarketplaceStoragePath
			)       

			// add marketplace capability to admin resource
			let marketplaceCap = self.account.getCapability<&BlockRecordsSingle.Marketplace>(self.MarketplacePrivatePath)!
			
			// initialize and save admin resource
			let admin <- create Admin()
			admin.addCapability(cap: marketplaceCap)
			self.account.save(<- admin, to: self.AdminStoragePath)
			self.account.link<&BlockRecordsSingle.Admin>(self.AdminPrivatePath, target: self.AdminStoragePath)  

			emit ContractInitialized()
	}
}


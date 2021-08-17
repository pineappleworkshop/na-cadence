
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS

// todo: encapsulate much of this funcationality into different smart contracts
// 
pub contract BlockRecordsRelease {

	//events
	//
	pub event ContractInitialized()
	pub event Event(type: String, metadata: {String: String})

	// named paths
	//
	pub let CreatorStoragePath: StoragePath
	pub let CreatorPublicPath: PublicPath

	pub let CollectionStoragePath: StoragePath
	pub let CollectionPublicPath: PublicPath
	
	// the total number of BlockRecordsReleases that have been created
	//
	pub var totalSupply: UInt64

	pub resource interface ReleaseCollectionPublic {
		pub fun borrowRelease(_ id: UInt64): &Release
	}

	// any account in posession of a ReleaseCollection will be able to mint BlockRecords NFTs
	// this is secure because "transactions cannot create resource types outside of containing contracts"
	pub resource ReleaseCollection: ReleaseCollectionPublic {  

		// creator profile resource
		pub var creatorProfile: CreatorProfile

		// dictionary of releases in the collection
		pub var releases: @{UInt64: Release}

		init(
			creatorStageName: String,
			creatorLegalName: String,
			creatorImageURL: String,
			creatorAddress: Address
		){
			self.creatorProfile = CreatorProfile(
				stageName: creatorStageName,
				legalName: creatorLegalName,
				imageURL: creatorImageURL,
				address: creatorAddress
			)

			self.releases <- {}
		}

		// refer to https://github.com/versus-flow/versus-contracts/blob/master/contracts/Versus.cdc#L429
		pub fun createAndAddRelease(
			name: String,
			description: String,
			type: String,
			fusdVault: Capability<&{FungibleToken.Receiver}>,
			percentFee: UFix64
		){
			// pre {
			//     royaltyVault.check() == true : "Vault capability should exist"
			// }

			let release <- create Release(
				name: name,
				description: description,
				type: type,
				fusdVault: fusdVault,
				percentFee: percentFee
			)

			// emit event
			emit Event(type: "release_created", metadata: {
				"id" : release.id.toString()
			})

			// add release to release collection dictionary
			let oldRelease <- self.releases[release.id] <- release
			destroy oldRelease
		}

		// todo: review this... should be pub or access(contract)?
		// access(contract) fun getRelease(_ id:UInt64) : &Release {
		pub fun borrowRelease(_ id: UInt64) : &Release {
			pre {
				self.releases[id] != nil : "release doesn't exist"
			}
			return &self.releases[id] as &Release
		}

		destroy(){
			destroy self.releases
		}
	}

	pub resource interface ReleasePublic {
		pub let id: UInt64
		pub let name: String
		pub let description: String
		pub let type: String
		pub var nftIDs: [UInt64]
		pub var completed: Bool
		pub let payout: Payout
	}

	// acts as the root resource for any NFT minted by a creator
	// all singles, albums, etc... must be associated with a release
	pub resource Release: ReleasePublic {

		// unique id of the release
		pub let id: UInt64

		// name of the release
		pub let name: String

		// the description of the release
		pub let description: String
		
		// "type" of release
		pub let type: String

		// ids of nfts associated with release
		pub var nftIDs: [UInt64]

		// specifies that all NFTs that should be added, were added
		// maybe: allows the associated nfts to be listed for sale
		pub var completed: Bool

		// the sale fee cut for the release creator
		pub let payout: BlockRecordsMarketplace.Payout

		init(
			name: String,
			description: String,
			type: String,
			fusdVault: Capability<&{FungibleToken.Receiver}>,
			percentFee: UFix64
		){
			self.name = name
			self.description = description
			self.type = type

			self.payout = Payout(
				fusdVault: fusdVault,
				percentFee: percentFee
			)

			self.nftIDs = []
			self.completed = false

			self.id = BlockRecordsNFT.totalSupply

			// iterate supply
			BlockRecordsNFT.totalSupply = BlockRecordsNFT.totalSupply + (1 as UInt64)
		}

		pub fun complete(){
				self.completed = true
		}

		// mints a new BlockRecordsNFT, adds ID to release, and deposits into minter's nft collection
		pub fun mintAndAddSingle(
			name: String, 
			type: String, 
			literation: String, 
			imageURL: String, 
			audioURL: String,
			serialNumber: UInt64,
			releaseID: UInt64,
			receiverCollection: &{NonFungibleToken.CollectionPublic}
		){
			pre {
				!self.completed : "cannot add to completed release"
				
				// validate nft type
				// BlockRecordsNFT.NFTTypes.contains(type) : "invalid nft type"
			}
					
			let id =  BlockRecordsNFT.totalSupply

			let single <- create BlockRecordsNFT.NFT(
				id: id, 
				name: name, 
				type: type, 
				literation: literation, 
				imageURL: imageURL, 
				audioURL: audioURL,
				serialNumber: serialNumber,
				releaseID: releaseID
			)

			// append id to release collection
			self.nftIDs.append(single.id)

			// deposit into minter's own collection
			receiverCollection.deposit(
				token: <- single
			)

			emit Event(type: "minted", metadata: {
				"id" : id.toString(),
				"name": name,
				"type": type,
				"literation": literation,
				"image_url": imageURL,
				"audio_url": audioURL,
				"serial_number": serialNumber.toString(),
				"release_id": releaseID.toString()
			})
		}
	}

	// potential creator accounts will create a public capability to this
	// so that a BlockRecords admin can add the minter capability
	pub resource interface CreatorPublic {
			pub fun addCapability(cap: Capability<&ReleaseCollection>, address: Address)
	}

	// accounts can create creator resource but, will not be able to mint without
	// the ReleaseCollection capability
	pub fun createCreator(): @Creator {
			return <- create Creator()
	}

	// resource that a creator would own to be able to mint their own NFTs
	// 
	pub resource Creator: CreatorPublic {
		access(account) var releaseCollectionCapability: Capability<&ReleaseCollection>?

		init() {
			self.releaseCollectionCapability = nil
		}

		pub fun addCapability(cap: Capability<&ReleaseCollection>, address: Address) {
			pre {
				cap.check() : "invalid capability"
				self.releaseCollectionCapability == nil : "capability already set"
			}
			
			emit Event(type: "creator_authorized", metadata: {
				"address": address.toString()
			})

			self.releaseCollectionCapability = cap
		}

		pub fun createRelease(
			name: String,
			description: String,
			type: String,
			fusdVault: Capability<&{FungibleToken.Receiver}>,
			percentFee: UFix64
		){
			// accounts cannot create new releases without release collection capability
			pre {
				self.releaseCollectionCapability != nil: "not an authorized creator"
			}

			// create release and add to release collection
			self.releaseCollectionCapability!.borrow()!.createAndAddRelease(
				name: name,
				description: description,
				type:type,
				fusdVault: fusdVault,
				percentFee: percentFee
			)
		}

		pub fun mintSingle(
			name: String, 
			type: String, 
			literation: String, 
			imageURL: String, 
			audioURL: String,
			copiesCount: Int,
			releaseID: UInt64,
			receiverCollection: &{NonFungibleToken.CollectionPublic}
		){
			pre {
				self.releaseCollectionCapability != nil: "not an authorized creator"
			}

			var serialNumber = 1
			while serialNumber <= copiesCount {

				let id =  BlockRecordsNFT.totalSupply

				self.releaseCollectionCapability!.borrow()!.borrowRelease(releaseID).mintAndAddSingle(
					name: name, 
					type: type, 
					literation: literation, 
					imageURL: imageURL, 
					audioURL: audioURL,
					serialNumber: UInt64(serialNumber),
					releaseID: releaseID,
					receiverCollection: receiverCollection
				)

				// increment serial number
				serialNumber = serialNumber + 1
			}
		}
	}

	// the creator's profile info
	pub struct CreatorProfile {

		// creator's stage name or pseudonym
		pub var stageName: String

		// creator's legal full name
		pub var legalName: String

		// creator's desired profile picture url
		pub var imageURL: String

		// creator's account address
		// this can be changed if the creator loses their credentials.
		// just unlink the private capability and create a new one,
		// then update creator profile struct in release collection.
		// NOTE: it is important to keep this reference in the release collection resource *only*
		// so there won't be discrepencies downstream if the creator's address changes
		pub var address: Address

		init(
			stageName: String, 
			legalName: String,
			imageURL: String,
			address: Address
		){
			self.stageName = stageName
			self.legalName = legalName
			self.imageURL = imageURL
			self.address = address
		}
	}
		
	init() {
		self.CreatorStoragePath = /storage/BlockRecordsCreator
		self.CreatorPublicPath = /public/BlockRecordsCreator

		self.CollectionStoragePath = /storage/BlockRecordsReleaseCollection
		self.CollectionPublicPath = /public/BlockRecordsReleaseCollection

		emit ContractInitialized()
	}
}

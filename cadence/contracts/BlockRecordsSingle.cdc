import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// todo: encapsulate much of this funcationality into different smart contracts
// 
pub contract BlockRecordsSingle: NonFungibleToken {

    //events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, metadata: {String: String}
    )
    pub event Event(type: String, metadata: {String: String})

    // named paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    pub let CreatorStoragePath: StoragePath
    pub let CreatorPublicPath: PublicPath

    pub let ReleaseCollectionStoragePath: StoragePath
    pub let ReleaseCollectionPublicPath: PublicPath

    pub let MarketplaceStoragePath: StoragePath
    pub let MarketplacePublicPath: PublicPath
    pub let MarketplacePrivatePath: PrivatePath

    pub let AdminPrivatePath: PrivatePath
    pub let AdminStoragePath: StoragePath

    // global constants
    //
    pub let NFTTypes: [String]
    
    // the total number of BlockRecordsSingle that have been minted
    //
    pub var totalSupply: UInt64

    pub struct Payout {
        // the vault that  on the payout will be distributed to
        pub let fusdVault: Capability<&{FungibleToken.Receiver}>

        // percentage percentFee of the sale that will be paid out to the marketplace vault
        pub let percentFee: UFix64 

        init(
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64
        ){
            self.fusdVault = fusdVault
            self.percentFee = percentFee
        }
    }

    pub resource interface MarketplacePublic {
        pub let name: String
        pub let payout: Payout
    }

    // any account in posession of a Marketplace capability will be able to create release collections
    // 
    pub resource Marketplace: MarketplacePublic {  

        // name of the marketplace
        pub let name: String

        // the sale fee cut of the marketplace
        pub let payout: Payout

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
        }
    }

    pub resource interface AdminPublic {
        pub fun addCapability(cap: Capability<&Marketplace>)
    }

    // accounts can create creator resource but will need to be authorized
    pub fun createAdmin(): @Admin {
        return <- create Admin()
    }

    // resource that a admin would own to be able to create Release Collections
    // 
	pub resource Admin: AdminPublic {

        //ownership of this capability allows for the creation of Release Collections
        access(contract) var marketplaceCapability: Capability<&Marketplace>?

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

            // todo: emit release created

            // add release to release collection dictionary
            let oldRelease <- self.releases[release.id] <- release
            destroy oldRelease
        }

        // todo: review this... should be pub or access(contract)?
        // access(contract) fun getRelease(_ id:UInt64) : &Release {
        pub fun borrowRelease(_ id: UInt64) : &Release {
            pre {
                self.releases[id] != nil:
                    "release doesn't exist"
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
        pub let payout: Payout

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

            self.id = BlockRecordsSingle.totalSupply

            // iterate supply
            BlockRecordsSingle.totalSupply = BlockRecordsSingle.totalSupply + (1 as UInt64)
        }

        pub fun complete(){
            self.completed = true
        }

        // mints a new BlockRecordsSingle, adds ID to release, and deposits into minter's nft collection
		pub fun mintAndAddSingle(
            name: String, 
            type: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            releaseID: UInt64,
            receiverCollection: &{NonFungibleToken.CollectionPublic}
        ){
            pre {
                !self.completed : "cannot add to completed release"
                
                // validate nft type
                BlockRecordsSingle.NFTTypes.contains(type) : "invalid nft type"
            }

            let id =  BlockRecordsSingle.totalSupply

            emit Event(type: "minted", metadata: {
                "id" : id.toString(),
                "name": name,
                "type": type,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL,
                "release_id": releaseID.toString()
            })

            let single <- create BlockRecordsSingle.NFT(
                id: id, 
                name: name, 
                type: type, 
                literation: literation, 
                imageURL: imageURL, 
                audioURL: audioURL,
                releaseID: releaseID
            )

            // append id to release collection
            self.nftIDs.append(single.id)

            // deposit into minter's own collection
			receiverCollection.deposit(
                token: <- single
            )

            BlockRecordsSingle.totalSupply = BlockRecordsSingle.totalSupply + (1 as UInt64)
		}

        // todo: album
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
        access(contract) var releaseCollectionCapability: Capability<&ReleaseCollection>?

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
            releaseID: UInt64,
            receiverCollection: &{NonFungibleToken.CollectionPublic}
        ){
             pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
            }

            self.releaseCollectionCapability!.borrow()!.borrowRelease(releaseID).mintAndAddSingle(
                name: name, 
                type: type, 
                literation: literation, 
                imageURL: imageURL, 
                audioURL: audioURL,
                releaseID: releaseID,
                receiverCollection: receiverCollection
            )
        }
	}

    // the BlockRecordsSingle NFT resource
    //
    pub resource NFT: NonFungibleToken.INFT {
        
        // unique id of nft
        pub let id: UInt64

        // metadata is a dictionary of strings so our fields are mutable
        pub var metadata: {String: AnyStruct}

        init(
            id: UInt64, 
            name: String, 
            type: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            releaseID: UInt64
        ) {
            self.id = id

            self.metadata = {
                "name":name,
                "type": type,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL,
                "release_id": releaseID
            }
        }
    }

    // this is the interface that users can cast their BlockRecordsSingle Collection as
    // to allow others to deposit BlockRecordsSingle into their Collection. It also allows for reading
    // the details of BlockRecordsSingle in the Collection.
    pub resource interface BlockRecordsSingleCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowBlockRecordsSingle(id: UInt64): &BlockRecordsSingle.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "cannot borrow BlockRecordsSingle reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // a collection of BlockRecordsSingle NFTs owned by an account
    //
    pub resource Collection: BlockRecordsSingleCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            let ownerAddress = self.owner?.address!.toString()

            emit Event(type: "withdrawn", metadata: {
                "id" : token.id.toString(),
                "owner_address": ownerAddress
            })

            return <-token
        }

        // takes an NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @BlockRecordsSingle.NFT
            let id: UInt64 = token.id
            let ownerAddress = self.owner?.address!.toString()
            let oldToken <- self.ownedNFTs[id] <- token

            emit Event(type: "deposited", metadata: {
                "id" : id.toString(),
                "owner_address": ownerAddress
            })

            destroy oldToken
        }

        // returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // gets a reference to an NFT in the collection as a BlockRecordsSingle,
        // exposing all of its fields (including the img).
        // his is safe as there are no functions that can be called on the BlockRecordsSingle.
        //
        pub fun borrowBlockRecordsSingle(id: UInt64): &BlockRecordsSingle.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &BlockRecordsSingle.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // get a reference to a BlockRecordsSingle from an account's Collection, if available.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &BlockRecordsSingle.NFT? {
        let collection = getAccount(from)
            .getCapability(BlockRecordsSingle.CollectionPublicPath)!
            .borrow<&BlockRecordsSingle.Collection{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
            ?? panic("couldn't get collection")
        // We trust BlockRecordsSingle.Collection.borowBlockRecords to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowBlockRecordsSingle(id: itemID)
    }

	init() {
        self.CollectionStoragePath = /storage/BlockRecordsSingleCollection002
        self.CollectionPublicPath = /public/BlockRecordsSingleCollection002

        self.CreatorStoragePath = /storage/BlockRecordsCreator002
        self.CreatorPublicPath = /public/BlockRecordsCreator002

        self.ReleaseCollectionStoragePath = /storage/BlockRecordsReleaseCollection002
        self.ReleaseCollectionPublicPath = /public/BlockRecordsReleaseCollection002

        self.MarketplaceStoragePath = /storage/BlockRecordsMarketplace002
        self.MarketplacePublicPath = /public/BlockRecordsMarketplace002
        self.MarketplacePrivatePath = /private/BlockRecordsMarketplace002
        
        self.AdminPrivatePath = /private/BlockRecordsAdmin002
        self.AdminStoragePath = /storage/BlockRecordsAdmin002
        
        // total supply of all block records resources: releases, nfts, etc...
        self.totalSupply = 0

        // supported NFT types
        self.NFTTypes = [
            "single"
        ]

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
        self.account.link<&BlockRecordsSingle.Marketplace{BlockRecordsSingle.MarketplacePublic}>(
            self.MarketplacePrivatePath,
            target: self.MarketplaceStoragePath
        )       

        // add marketplace capability to admin resource
        let marketplaceCap = self.account.getCapability<&BlockRecordsSingle.Marketplace>(self.MarketplacePrivatePath)!
        
        // initialize and save admin resource
        let admin <- create Admin()
        admin.addCapability(cap: marketplaceCap)
        self.account.save(<- admin, to: self.AdminStoragePath)

        emit ContractInitialized()
	}
}

import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// todo: currently, any authorized creator can add an NFT to any release
// we need to create capabilities for each new release so that only the owner
// can modify it

// todo: encapsulate much of this funcationality into different smart contracts
// 
pub contract BlockRecordsSingle: NonFungibleToken {

    //events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(
        id: UInt64, 
        metadata: {String: String}
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

    // global constants
    //
    pub let NFTTypes: [String]
    pub let Fee: UFix64
    
    // the total number of BlockRecordsSingle that have been minted
    //
    pub var totalSupply: UInt64

    // any account in posession of a Marketplace capability will be able to create releases
    // 
    pub resource Marketplace {  

        // name of the marketplace
        pub let name: String

        // the vault that sale fees on the marketplace will be paid out to
        pub let fusdVault: Capability<&{FungibleToken.Receiver}>

        // percentage fee of the sale that will be paid out to the marketplace vault
        pub let fee: UFix64 

        init(
            name: String,
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            fee: UFix64
        ){
            self.name = name
            self.fusdVault = fusdVault
            self.fee = fee
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

        // todo: methods to update values
    }

    // any account in posession of a ReleaseCollection will be able to mint BlockRecords NFTs
    // this is secure because "transactions cannot create resource types outside of containing contracts"
    pub resource ReleaseCollection {  

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
            type: String
        ){
            // pre {
            //     royaltyVault.check() == true : "Vault capability should exist"
            // }

            let release <- create Release(
                name: name,
                description: description,
                type: type
            )

            // todo: emit release created

            // add release to release collection dictionary
            let oldRelease <- self.releases[release.id] <- release
            destroy oldRelease
        }

        // todo: review this... should be pub or access(contract)?
        // access(contract) fun getRelease(_ id:UInt64) : &Release {
        pub fun getRelease(_ id: UInt64) : &Release {
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


    // acts as the root resource for any NFT minted by a creator
    // all singles, albums, etc... must be associated with a release
    pub resource Release {

        // unique id of the release
        pub let id: UInt64

        // name of the release
        pub let name: String

        // the description of the release
        pub let description: String
        
        // "type" of release
        pub let type: String

        // ids of nfts associated with release
        pub let nftIDs: [UInt64]

        // specifies that all NFTs that should be added, were added
        // maybe: allows the associated nfts to be listed for sale
        pub var completed: Bool
        
        init(
            name: String,
            description: String,
            type: String
        ){
            self.name = name
            self.description = description
            self.type = type
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
            royaltyAddress: Address, 
            royaltyPercentage: UInt64, 
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
                "royalty_address": royaltyAddress.toString(),
                "royalty_percentage": royaltyPercentage.toString(),
                "type": type,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL,
                "release_id": releaseID.toString()
            })

            let single <- create BlockRecordsSingle.NFT(
                id: id, 
                name: name, 
                royaltyAddress: royaltyAddress, 
                royaltyPercentage: royaltyPercentage, 
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
            type: String
        ){
            // accounts cannot create new releases without release collection capability
             pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
            }

            // create release
            self.releaseCollectionCapability!.borrow()!.createAndAddRelease(
                name: name,
                description: description,
                type:type
            )
        }

        pub fun mintSingle(
            name: String, 
            royaltyAddress: Address, 
            royaltyPercentage: UInt64, 
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

            self.releaseCollectionCapability!.borrow()!.getRelease(releaseID).mintAndAddSingle(
                name: name, 
                royaltyAddress: royaltyAddress, 
                royaltyPercentage: royaltyPercentage, 
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
            royaltyAddress: Address, 
            royaltyPercentage: UInt64, 
            type: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            releaseID: UInt64
        ) {
            self.id = id

            self.metadata = {
                "name":name,
                "royalty_address": royaltyAddress,
                "royalty_percentage": royaltyPercentage,
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

        self.totalSupply = 0

        // supported NFT types
        let NFT_TYPE_SINGLE = "single"
        self.NFTTypes = []
        self.NFTTypes.append(NFT_TYPE_SINGLE)

        self.Fee = 0.05

        // initialize FUSD vault for service account so that we can receive 
        // sale fees and check balance
        self.account.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
        self.account.link<&FUSD.Vault{FungibleToken.Receiver}>(
          /public/fusdReceiver,
          target: /storage/fusdVault
        )
        self.account.link<&FUSD.Vault{FungibleToken.Balance}>(
          /public/fusdBalance,
          target: /storage/fusdVault
        )

        // let marketplaceVault = self.account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!

        // let releaseCollection <- create ReleaseCollection(marketplaceVault: marketplaceVault,  marketplaceFee: marketplaceFee)
        // self.account.save(<- releaseCollection, to: self.ReleaseCollectionStoragePath)

        emit ContractInitialized()
	}
}

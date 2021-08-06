import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// todo: change name of contract to BlockRecords
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
    
    // the total number of BlockRecordsSingle that have been minted
    //
    pub var totalSupply: UInt64

    // the BlockRecordsSingle NFT resource
    //
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub var metadata: {String: AnyStruct}

        init(
            id: UInt64, 
            minterAddress: Address, 
            name: String, 
            royaltyAddress: Address, 
            royaltyPercentage: UInt64, 
            type: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String
        ) {
            self.id = id

            // todo: validate type
            // single, album, etc...

            self.metadata = {
                "minter_address": minterAddress,
                "name":name,
                "royalty_address": royaltyAddress,
                "royalty_percentage": royaltyPercentage,
                "type": type,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL,
                "minter_address": minterAddress
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

        // takes a NFT and adds it to the collections dictionary
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

    // acts as the root resource for any NFT minted by a creator
    // all singles, albums, etc... must be associated with a release
    pub resource Release {

        pub let id: UInt64
        
        // address that sale royalties will be paid out to
        pub let royaltyVault: Capability<&{FungibleToken.Receiver}>

        // percentage fee of the sale that will be paid out to the royalty address
        pub let royaltyFee: UFix64

        // ids of nfts associated with release
        pub let nftIDs: [UInt64]

        // specifies that all NFTs that should be added, were added
        // maybe: allows the associated nfts to be listed for sale
        pub var completed: Bool

        init(
            royaltyVault: Capability<&{FungibleToken.Receiver}>,
            royaltyFee: UFix64
        ){
            self.royaltyVault = royaltyVault
            self.royaltyFee = royaltyFee
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
            receiverCollection: &{NonFungibleToken.CollectionPublic}
        ){
            pre {
                !self.completed : "cannot add to completed release"
            }

            let id =  BlockRecordsSingle.totalSupply
            let minterAddress = self.owner?.address!

            emit Event(type: "minted", metadata: {
                "id" : id.toString(),
                "minter_address": minterAddress.toString(),
                "name": name,
                "royalty_address": royaltyAddress.toString(),
                "royalty_percentage": royaltyPercentage.toString(),
                "type": type,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL
            })

            let single <- create BlockRecordsSingle.NFT(
                id: id, 
                minterAddress: minterAddress, 
                name: name, 
                royaltyAddress: royaltyAddress, 
                royaltyPercentage: royaltyPercentage, 
                type: type, 
                literation: literation, 
                imageURL: imageURL, 
                audioURL: audioURL
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

    // any account in posession of a ReleaseCollection will be able to mint BlockRecords NFTs
    // this is secure because "transactions cannot create resource types outside of containing contracts"
    pub resource ReleaseCollection {  

        // dictionary of releases in the collection
        pub var releases: @{UInt64: Release}

        // the BlockRecords address that the sale fees will be paid out to
        pub let marketplaceVault: Capability<&{FungibleToken.Receiver}>

        // percentage fee of the sale that will be paid out to the marketplace address
        pub let marketplaceFee: UFix64 

        init(
            marketplaceVault: Capability<&{FungibleToken.Receiver}>,
            marketplaceFee: UFix64
        ){
            self.marketplaceVault = marketplaceVault
            self.marketplaceFee = marketplaceFee
            self.releases <- {}
        }

        // refer to https://github.com/versus-flow/versus-contracts/blob/master/contracts/Versus.cdc#L429
        pub fun createAndAddRelease(
            royaltyVault: Capability<&{FungibleToken.Receiver}>,
            royaltyFee: UFix64
        ){
            pre {
                royaltyVault.check() == true : "Vault capability should exist"
            }

            let release <- create Release(
                royaltyVault: royaltyVault,
                royaltyFee: royaltyFee 
            )

            // todo: emit release created

            // todo: is this correct?
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

    // accounts can create nft minter but, will not be able to mint without
    //
    access(account) fun createReleaseCollection(
        marketplaceVault: Capability<&{FungibleToken.Receiver}>,
        marketplaceFee: UFix64
    ): @ReleaseCollection {
        return <- create ReleaseCollection(
            marketplaceVault: marketplaceVault,
            marketplaceFee: marketplaceFee
        )
    }

    // potential creator accounts will create a public capability to this
    // so that a BlockRecords admin can add the minter capability
    pub resource interface CreatorPublic {
        pub fun addCapability(cap: Capability<&ReleaseCollection>)
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

        pub fun addCapability(cap: Capability<&ReleaseCollection>) {
            pre {
                cap.check() : "invalid capability"
                self.releaseCollectionCapability == nil : "capability already set"
            }
            
            // todo:
            // emit Event(type: "creator_authorized", metadata: {
            //     "address": self.
            // })

            self.releaseCollectionCapability = cap
        }

        pub fun createRelease(
            royaltyVault: Capability<&{FungibleToken.Receiver}>,
            royaltyFee: UFix64
        ){
            // accounts cannot create new releases without release collection capability
             pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
            }

            // create release
            self.releaseCollectionCapability!.borrow()!.createAndAddRelease(
                royaltyVault: royaltyVault,
                royaltyFee: royaltyFee 
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
                receiverCollection: receiverCollection
            )
        }
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

        let marketplaceVault = self.account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        let marketplaceFee = 0.05

        let releaseCollection <- create ReleaseCollection(marketplaceVault: marketplaceVault,  marketplaceFee: marketplaceFee)
        self.account.save(<- releaseCollection, to: self.ReleaseCollectionStoragePath)

        emit ContractInitialized()
	}
}

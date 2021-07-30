import NonFungibleToken from SERVICE_ACCOUNT_ADDRESS


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
    pub let CreatorPrivatePathPrefix: String
    pub let ReleaseCollectionStoragePath: StoragePath
    pub let ReleaseCollectionPublicPath: PublicPath
    pub let ReleaseCollectionPrivatePath: PrivatePath
    
    // the total number of BlockRecordsSingle that have been minted
    //
    pub var totalSupply: UInt64

    // the BlockRecordsSingle NFT resource
    //
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub var metadata: {String: AnyStruct}

        init(id: UInt64, minterAddress: Address, name: String, royaltyAddress: Address, royaltyPercentage: UInt64, type: String, literation: String, imageURL: String, audioURL: String) {
            self.id = id
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

    // any account in posession of a ReleaseCollection will be able to mint BlockRecords NFTs
    // this is secure because "transactions cannot create resource types outside of containing contracts"
    pub resource ReleaseCollection {        
        init(){}

        // todo: pub fun create release 
        // refer to https://github.com/versus-flow/versus-contracts/blob/master/contracts/Versus.cdc#L429
    }

    // accounts can create nft minter but, will not be able to mint without
    //
    access(account) fun createReleaseCollection(): @ReleaseCollection {
        return <- create ReleaseCollection()
    }


    // potential creator accounts will create a public capability to this
    // so that a BlockRecords admin can add the minter capability
    pub resource interface CreatorPublic {
        pub fun addCapability(cap: Capability<&ReleaseCollection>)
    }

    // accounts can create nft minter but, will not be able to mint without
    // the minter capability
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
                cap.borrow() != nil: "invalid capability"
            }
            self.releaseCollectionCapability = cap
        }

        // mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, name: String, royaltyAddress: Address, royaltyPercentage: UInt64, type: String, literation: String, imageURL: String, audioURL: String) {

            // accounts cannot mint without minter capability
             pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
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

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create BlockRecordsSingle.NFT(id: id, minterAddress: minterAddress, name: name, royaltyAddress: royaltyAddress, royaltyPercentage: royaltyPercentage, type: type, literation: literation, imageURL: imageURL, audioURL: audioURL))

            BlockRecordsSingle.totalSupply = BlockRecordsSingle.totalSupply + (1 as UInt64)
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
        self.CreatorPrivatePathPrefix = "BlockRecordsCreator"

        self.ReleaseCollectionStoragePath = /storage/BlockRecordsReleaseCollection002
        self.ReleaseCollectionPublicPath = /public/BlockRecordsReleaseCollection002
        self.ReleaseCollectionPrivatePath = /private/BlockRecordsReleaseCollection002

        self.totalSupply = 0

        let releaseCollection <- create ReleaseCollection()
        self.account.save(<- releaseCollection, to: self.ReleaseCollectionStoragePath)

        emit ContractInitialized()
	}
}

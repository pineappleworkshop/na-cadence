import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS

pub contract BlockRecordsSingle: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    pub event Minted(
        id: UInt64, 
        metadata: {String: String}
    )

    pub event Event(type: String, metadata: {String: String})

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath
    pub let MinterPublicPath: PublicPath
    
    // totalSupply
    // The total number of BlockRecordsSingle that have been minted
    //
    pub var totalSupply: UInt64

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

    // This is the interface that users can cast their BlockRecordsSingle Collection as
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
                    "Cannot borrow BlockRecordsSingle reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of BlockRecordsSingle NFTs owned by an account
    //
    pub resource Collection: BlockRecordsSingleCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
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

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @BlockRecordsSingle.NFT

            let id: UInt64 = token.id

            let ownerAddress = self.owner?.address!.toString()

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Event(type: "deposited", metadata: {
                "id" : id.toString(),
                "owner_address": ownerAddress
            })

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowBlockRecordsSingle
        // Gets a reference to an NFT in the collection as a BlockRecordsSingle,
        // exposing all of its fields (including the img).
        // This is safe as there are no functions that can be called on the BlockRecordsSingle.
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

    // accounts can create nft minter but, will not be able to mint without
    // the minter capability
    pub fun createNFTMinter(): @NFTMinter {
        // todo: emit event
        return <- create NFTMinter()
    }

    pub resource Minter {
        // todo: what should go in here?
    }

    // potential minter accounts will create a public capability to this
    // so that the admin can add the minter capability
    pub resource interface NFTMinterPublic {
        pub fun addMinterCapability(cap: Capability<&Minter>)
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter: NFTMinterPublic {

        access(self) var minterCapability: Capability<&Minter>?

        init() {
            self.minterCapability = nil
        }

        pub fun addMinterCapability(cap: Capability<&Minter>) {
            pre {
                cap.borrow() != nil: "Invalid capability"
            }
            self.minterCapability = cap
        }

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, name: String, royaltyAddress: Address, royaltyPercentage: UInt64, type: String, literation: String, imageURL: String, audioURL: String) {

            // accounts cannot mint without minter capability
             pre {
                self.minterCapability != nil: "Cannot mint until the admin has deposited the minter capability"
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

    // fetch
    // Get a reference to a BlockRecordsSingle from an account's Collection, if available.
    // If an account does not have a BlockRecordsSingle.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &BlockRecordsSingle.NFT? {
        let collection = getAccount(from)
            .getCapability(BlockRecordsSingle.CollectionPublicPath)!
            .borrow<&BlockRecordsSingle.Collection{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust BlockRecordsSingle.Collection.borowBlockRecords to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowBlockRecordsSingle(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        //FIXME: REMOVE SUFFIX BEFORE RELEASE
        self.CollectionStoragePath = /storage/BlockRecordsSingleCollection002
        self.CollectionPublicPath = /public/BlockRecordsSingleCollection002
        self.MinterStoragePath = /storage/BlockRecordsMinter002
        self.MinterPublicPath = /public/BlockRecordsMinter002

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}

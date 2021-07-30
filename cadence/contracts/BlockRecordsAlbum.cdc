import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

// WORK IN PROGRESS, NOT CURRENTLY IN USE

pub contract BlockRecordsAlbum: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, metadata: {String: String})

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // totalSupply
    // The total number of BlockRecordsAlbum that have been minted
    //
    pub var totalSupply: UInt64

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64

        pub var metadata: {String: String}

        init(initID: UInt64, initMetadata: {String: String} ) {
            self.id = initID
            self.metadata = initMetadata
        }
    }

    // This is the interface that users can cast their BlockRecordsAlbum Collection as
    // to allow others to deposit BlockRecordsAlbum into their Collection. It also allows for reading
    // the details of BlockRecordsAlbum in the Collection.
    pub resource interface BlockRecordsAlbumCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowBlockRecordsSingle(id: UInt64): &BlockRecordsAlbum.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow BlockRecordsAlbum reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of BlockRecordsAlbum NFTs owned by an account
    //
    pub resource Collection: BlockRecordsAlbumCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @BlockRecordsAlbum.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

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
        // Gets a reference to an NFT in the collection as a BlockRecordsAlbum,
        // exposing all of its fields (including the img).
        // This is safe as there are no functions that can be called on the BlockRecordsAlbum.
        //
        pub fun borrowBlockRecordsSingle(id: UInt64): &BlockRecordsAlbum.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &BlockRecordsAlbum.NFT
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

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(signer: AuthAccount, recordIDs: [UInt64], metadata: {String: String}) {

            let blockRecordsCollection = signer.getCapability(BlockRecordsSingle.CollectionPublicPath)!
            .borrow<&{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
            ?? panic("Could not borrow BlockRecordsSingleCollectionPublic")

            // verify that signer owns specified records
            for recordID in recordIDs {
                blockRecordsCollection.borrowBlockRecordsSingle(id: recordID) ?? panic("No such id in that collection")
            }

            let recipient = signer.getCapability(BlockRecordsAlbum.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

            emit Minted(id: BlockRecordsAlbum.totalSupply, metadata: metadata)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create BlockRecordsAlbum.NFT(initID: BlockRecordsAlbum.totalSupply, initMetadata: metadata))

            BlockRecordsAlbum.totalSupply = BlockRecordsAlbum.totalSupply + (1 as UInt64)
		}
	}

    // fetch
    // Get a reference to a BlockRecordsAlbum from an account's Collection, if available.
    // If an account does not have a BlockRecordsAlbum.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &BlockRecordsAlbum.NFT? {
        let collection = getAccount(from)
            .getCapability(BlockRecordsAlbum.CollectionPublicPath)!
            .borrow<&BlockRecordsAlbum.Collection{BlockRecordsAlbum.BlockRecordsAlbumCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust BlockRecordsAlbum.Collection.borowBlockRecordsAlbum to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowBlockRecordsSingle(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        //FIXME: REMOVE SUFFIX BEFORE RELEASE
        self.CollectionStoragePath = /storage/BlockRecordsAlbumCollection002
        self.CollectionPublicPath = /public/BlockRecordsAlbumCollection002
        self.MinterStoragePath = /storage/BlockRecordsAlbumMinter002

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}

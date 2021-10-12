
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS

/** 

## BlockRecordsSingle is the basic NFT for Block Records 

Eventually, we will have a BlockRecordsAlbum smart contract as well that will
allow users to collect and combine multiple singles to create a "full" album.

**/

pub contract BlockRecordsSingle: NonFungibleToken {

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, metadata: {String: String})

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let CollectionProviderPath: PrivatePath

    // the total number of BlockRecordsSingle that have been minted
    pub var totalSupply: UInt64

    pub resource NFT: NonFungibleToken.INFT {
        
        // unique id of nft
        pub let id: UInt64

        // Stores all the metadata about the single as a string mapping
        // "This is not the long term way NFT metadata will be stored. It's a temporary
        // construct while we figure out a better way to do metadata." - flow team
        //
        pub let metadata: {String: AnyStruct}

        init(
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            serialNumber: Int,
            releaseID: UInt64,
            payouts: [BlockRecords.Payout]
        ){
            self.id = BlockRecordsSingle.totalSupply

            self.metadata = {
                "name": name,
                "literation": literation,
                "image": image,
                "audio": audio,
                "serialNumber": serialNumber,
                "releaseID": releaseID,
                "payouts": payouts
            }

            emit Minted(id: self.id, metadata:{
                "name": name,
                "literation": literation,
                "image": image,
                "audio": audio,
                "serial_number": serialNumber.toString(),
                "release_id": releaseID.toString()
            })

            // increment id
            BlockRecordsSingle.totalSupply = BlockRecordsSingle.totalSupply + (1 as UInt64)
        }
    }

    // other contracts owned by the account may mint singles
    access(account) fun mint(
        name: String, 
        literation: String, 
        image: String, 
        audio: String,
        serialNumber: Int,
        releaseID: UInt64,
        payouts: [BlockRecords.Payout]
    ): @NFT {
        return <- create BlockRecordsSingle.NFT(
            name: name, 
            literation: literation, 
            image: image, 
            audio: audio,
            serialNumber: serialNumber,
            releaseID: releaseID,
            payouts: payouts
        )
    }

    // this is the interface that users can cast their BlockRecordsSingle Collection as
    // to allow others to deposit BlockRecordsSingle into their Collection. It also allows for reading
    // the details of BlockRecordsSingle in the Collection.
    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowSingle(id: UInt64): &BlockRecordsSingle.NFT? {
        // If the result isn't nil, the id of the returned reference
        // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id) : "cannot borrow BlockRecordsSingle reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // a collection of BlockRecordsSingle NFTs owned by an account
    //
    pub resource Collection: CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }


        // removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("missing NFT")
            let ownerAddress = self.owner?.address!

            emit Withdraw(id: token.id, from: ownerAddress)

            return <-token
        }

        // takes an NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @BlockRecordsSingle.NFT
            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token

            let ownerAddress = self.owner?.address!
            emit Deposit(id: id, to: ownerAddress)

            destroy oldToken
        }

        // returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // gets a reference to an NFT in the collection as a BlockRecordsSingle,
        // exposing all of its fields (including the img).
        // his is safe as there are no functions that can be called on the BlockRecordsSingle.
        pub fun borrowSingle(id: UInt64): &BlockRecordsSingle.NFT? {
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
        let collection = getAccount(from).getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&BlockRecordsSingle.Collection{BlockRecordsSingle.CollectionPublic}>()
            ?? panic("couldn't get collection")
        
        // We trust BlockRecordsSingle.Collection.borowBlockRecords to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowSingle(id: itemID)
    }

    init() {
        self.CollectionStoragePath = /storage/BlockRecordsSingleCollection
        self.CollectionPublicPath = /public/BlockRecordsSingleCollection
        self.CollectionProviderPath = /private/BlockRecordsCollectionProvider
        
        self.totalSupply = 0

        emit ContractInitialized()
    }
}

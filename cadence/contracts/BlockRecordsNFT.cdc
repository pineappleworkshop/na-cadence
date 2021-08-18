
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

/** 

BlockRecords NFTs
- single
- album (not yet implemented)

**/

pub contract BlockRecordsNFT: NonFungibleToken {

    //events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, metadata: {String: String})
    pub event Event(type: String, metadata: {String: String})

    // named paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    // global constants
    //
    pub let NFTTypes: [String]
    
    // the total number of BlockRecordsNFT that have been minted
    //
    pub var totalSupply: UInt64

    // the BlockRecordsNFT NFT resource
    //
    pub resource NFT: NonFungibleToken.INFT {
        
        // unique id of nft
        pub let id: UInt64

        // metadata is a dictionary of strings so our fields are mutable
        pub var metadata: {String: AnyStruct}

        pub let serialNumber: UInt64

        pub let releaseID: UInt64

        init(
            name: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            serialNumber: UInt64,
            releaseID: UInt64
        ){
            self.id = BlockRecordsNFT.totalSupply

            self.metadata = {
                "name": name,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL
            }

            self.serialNumber = serialNumber
            self.releaseID = releaseID

            emit Event(type: "minted", metadata: {
                "id" : self.id.toString(),
                "name": name,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL,
                "serial_number": serialNumber.toString(),
                "release_id": releaseID.toString()
            })

            // increment id
            BlockRecordsNFT.totalSupply = BlockRecordsNFT.totalSupply + (1 as UInt64)
        }
    }

    // other contracts owned by the account may mint singles
    access(account) fun mintSingle(
        name: String, 
        literation: String, 
        imageURL: String, 
        audioURL: String,
        serialNumber: UInt64,
        releaseID: UInt64
    ): @NFT {
        return <- create BlockRecordsNFT.NFT(
            name: name, 
            literation: literation, 
            imageURL: imageURL, 
            audioURL: audioURL,
            serialNumber: serialNumber,
            releaseID: releaseID
        )
    }

    // this is the interface that users can cast their BlockRecordsNFT Collection as
    // to allow others to deposit BlockRecordsNFT into their Collection. It also allows for reading
    // the details of BlockRecordsNFT in the Collection.
    pub resource interface BlockRecordsNFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowBlockRecordsNFT(id: UInt64): &BlockRecordsNFT.NFT? {
        // If the result isn't nil, the id of the returned reference
        // should be the same as the argument to the function
        post {
                (result == nil) || (result?.id == id) : "cannot borrow BlockRecordsNFT reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // a collection of BlockRecordsNFT NFTs owned by an account
    //
    pub resource Collection: BlockRecordsNFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("missing NFT")
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
            let token <- token as! @BlockRecordsNFT.NFT
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

        // gets a reference to an NFT in the collection as a BlockRecordsNFT,
        // exposing all of its fields (including the img).
        // his is safe as there are no functions that can be called on the BlockRecordsNFT.
        //
        pub fun borrowBlockRecordsNFT(id: UInt64): &BlockRecordsNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &BlockRecordsNFT.NFT
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

    // get a reference to a BlockRecordsNFT from an account's Collection, if available.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &BlockRecordsNFT.NFT? {
        let collection = getAccount(from).getCapability(BlockRecordsNFT.CollectionPublicPath)!.borrow<&BlockRecordsNFT.Collection{BlockRecordsNFT.BlockRecordsNFTCollectionPublic}>()
            ?? panic("couldn't get collection")
        
        // We trust BlockRecordsNFT.Collection.borowBlockRecords to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowBlockRecordsNFT(id: itemID)
    }

    init() {
        self.CollectionStoragePath = /storage/BlockRecordsNFTCollection
        self.CollectionPublicPath = /public/BlockRecordsNFTCollection
        
        // total supply of all block records resources: releases, nfts, etc...
        self.totalSupply = 0

        // supported NFT types
        self.NFTTypes = [
            "single"
        ]

        emit ContractInitialized()
    }
}

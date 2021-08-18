
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS

/** 

Releases are the root resource of any BlockRecords nft.

potential "creators" will create and save the creator resource to their storage and expose
its capability receiver function publicly. this allows the service account to create a unique
ReleaseCollection, save it to storage, create a private capability, and send that capability 
to the creator. the service account maintains the right to revoke this capability - blocking the
creator's access to their release collection - in the event that the creator violates our terms
and agreements.

**/

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

        // unique id of the release collection
        pub let id: UInt64

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

            self.id = BlockRecordsRelease.totalSupply

            self.creatorProfile = CreatorProfile(
                stageName: creatorStageName,
                legalName: creatorLegalName,
                imageURL: creatorImageURL,
                address: creatorAddress
            )

            // release collection was created for creator
            emit Event(type: "collection_created", metadata: {
                "id" : self.id.toString(),
                "creator_stage_name": creatorStageName,
                "creator_legal_name": creatorLegalName,
                "creator_image_url": creatorImageURL,
                "creator_address": creatorAddress.toString()
            })

            self.releases <- {}

            // iterate supply
            BlockRecordsRelease.totalSupply = BlockRecordsRelease.totalSupply + (1 as UInt64)
        }

        // refer to https://github.com/versus-flow/versus-contracts/blob/master/contracts/Versus.cdc#L429
        pub fun createAndAddRelease(
            type: String,
            name: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            copiesCount: UInt64,
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64
        ): UInt64 {
            pre {
                fusdVault.check() == true : "Vault capability should exist"
            }

            let release <- create Release(
                type: type,
                name: name, 
                literation: literation, 
                imageURL: imageURL, 
                audioURL: audioURL,
                copiesCount: copiesCount,
                fusdVault: fusdVault,
                percentFee: percentFee
            )

            let id = release.id

            // add release to release collection dictionary
            let oldRelease <- self.releases[id] <- release
            destroy oldRelease

            return id
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

    // other contracts owned by the account may create release collections
    access(account) fun createReleaseCollection(
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

    pub resource interface ReleasePublic {
        pub let id: UInt64
        pub var nftIDs: [UInt64]
        pub let metadata: {String: AnyStruct}
        pub let type: String
        pub var completed: Bool
        pub let payout: Payout
    }

    // acts as the root resource for any NFT minted by a creator
    // all singles, albums, etc... must be associated with a release
    pub resource Release: ReleasePublic {

        // unique id of the release
        pub let id: UInt64

        // "type" of release
        pub let type: String

        // metadata of the release
        pub let metadata: {String: AnyStruct}

        // NFT copies count
        pub let copiesCount: UInt64

        // ids of nfts associated with release
        pub var nftIDs: [UInt64]

        // the sale fee cut for the release creator
        pub let payout: Payout

        // specifies that all NFTs that should be added, were added
        pub var completed: Bool

        init(
            type: String,
            name: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            copiesCount: UInt64,
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64
        ){
            self.type = type

            self.metadata = {
                "name": name,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL
            }

            self.copiesCount = copiesCount

            self.payout = Payout(
                fusdVault: fusdVault,
                percentFee: percentFee
            )

            self.nftIDs = []
            self.completed = false

            self.id = BlockRecordsRelease.totalSupply

            // iterate supply
            BlockRecordsRelease.totalSupply = BlockRecordsRelease.totalSupply + (1 as UInt64)

            // emit event
            emit Event(type: "created", metadata: {
                "id" : self.id.toString(),
                "name": name,
                "literation": literation,
                "image_url": imageURL,
                "audio_url": audioURL,
                "copies_count": copiesCount.toString(),
                "percent_fee": percentFee.toString()
            })
        }

        pub fun complete(){
                self.completed = true
        }

        // mints a new BlockRecordsNFT, adds ID to release, and deposits into minter's nft collection
        pub fun mintAndAddSingle(
            name: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            serialNumber: UInt64,
            receiverCollection: &{NonFungibleToken.CollectionPublic}
        ){
            pre {
                !self.completed : "cannot add to completed release"
                
                // validate nft type
                // BlockRecordsNFT.NFTTypes.contains(type) : "invalid nft type"
            }
                    
            let single <- BlockRecordsNFT.mintSingle(
                name: name, 
                literation: literation, 
                imageURL: imageURL, 
                audioURL: audioURL,
                serialNumber: serialNumber,
                releaseID: self.id
            )

            // append id to release collection
            self.nftIDs.append(single.id)

            // deposit into minter's own collection
            receiverCollection.deposit(
                token: <- single
            )
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
            
            self.releaseCollectionCapability = cap

            emit Event(type: "collection_capability_added", metadata: {
                "collection_id": self.releaseCollectionCapability!.borrow()!.id.toString(),
                "creator_address": address.toString()
            })

        }

        pub fun createRelease(
            type: String,
            name: String, 
            literation: String, 
            imageURL: String, 
            audioURL: String,
            copiesCount: UInt64,
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64,
            receiverCollection: &{NonFungibleToken.CollectionPublic}
        ){
            pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
            }

            // borrow release collection
            let rc = self.releaseCollectionCapability!.borrow()!

            // create release and add to release collection
            let releaseID = rc.createAndAddRelease(
                type: type,
                name: name, 
                literation: literation, 
                imageURL: imageURL, 
                audioURL: audioURL,
                copiesCount: copiesCount,
                fusdVault: fusdVault,
                percentFee: percentFee
            )
            let release = rc.borrowRelease(releaseID)

            // create nfts and add them to release collection
            var serialNumber: UInt64 = 1
            while serialNumber <= copiesCount {
                release.mintAndAddSingle(
                    name: name, 
                    literation: literation, 
                    imageURL: imageURL, 
                    audioURL: audioURL,
                    serialNumber: UInt64(serialNumber),
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

    // todo: move this struct to another smart contract
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
        
    init() {
        self.CreatorStoragePath = /storage/BlockRecordsCreator
        self.CreatorPublicPath = /public/BlockRecordsCreator

        self.CollectionStoragePath = /storage/BlockRecordsReleaseCollection
        self.CollectionPublicPath = /public/BlockRecordsReleaseCollection

        self.totalSupply = 0

        emit ContractInitialized()
    }
}

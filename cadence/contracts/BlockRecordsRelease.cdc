
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS

/** 

Releases are the root resource of any BlockRecords nft.

potential "creators" will create and save the creator resource to their storage and expose
its capability receiver function publicly. this allows the service account to create a unique
Collection, save it to storage, create a private capability, and send that capability 
to the creator. the service account maintains the right to revoke this capability - blocking the
creator's access to their release collection - in the event that the creator violates our terms
and agreements.

**/

pub contract BlockRecordsRelease {

    //events
    //
    pub event ContractInitialized()
    
    pub event Created(
        id: UInt64, 
        metadata: {String: String}
    )
    
    pub event CollectionCreated(
        id: UInt64, 
        metadata: {String: String}
    )

    // named paths
    //
    pub let CreatorStoragePath: StoragePath
    pub let CreatorPublicPath: PublicPath

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    
    // the total number of Release Collections and Releases that have been created
    pub var totalSupply: UInt64

    pub resource interface CollectionPublic {
        pub fun getID(): UInt64
        pub fun getName(): String
        pub fun getDescription(): String
        pub fun getLogo(): String
        pub fun getBanner(): String
        pub fun getWebsite(): String
        pub fun getSocialMedias(): [String]
        pub fun borrowReleases(): [&Release]
        pub fun borrowReleaseByID(_ id: UInt64): &Release
    }

    // any account in posession of a Collection will be able to mint BlockRecords NFTs
    // this is secure because "transactions cannot create resource types outside of containing contracts"
    pub resource Collection: CollectionPublic {  
        // unique id of the release collection
        pub let id: UInt64

        // name of the release collection
        pub let name: String
        
        // description of the release collection
        pub let description: String

        // logo image will be used for featuring your collection on the homepage, category pages, etc...
        // 600 x 400 recommended
        pub let logo: String

        // banner image will appear at the top of your collection page
        // 1400 x 1400 recommended
        pub let banner: String

        // url of promotional website
        pub let website: String

        // social media urls
        pub let socialMedias: [String]

        // dictionary of releases in the collection
        pub var releases: @{UInt64: Release}

        init(
            name: String,
            description: String,
            logo: String,
            banner: String,
            website: String,
            socialMedias: [String]
        ){
            self.id = BlockRecordsRelease.totalSupply
            self.name = name
            self.description = description
            self.logo = logo
            self.banner = banner
            self.website = website
            self.socialMedias = socialMedias
            self.releases <- {}

            emit CollectionCreated(id: self.id, metadata: {
                "name": self.name,
                "description": self.description,
                "logo": self.logo,
                "banner": self.banner,
                "website": self.website
                // todo: social medias
            })

            // iterate supply
            BlockRecordsRelease.totalSupply = BlockRecordsRelease.totalSupply + (1 as UInt64)
        }

        // creates release,
        // creates nft(s) associated w/ release
        // deposits nfts in designated collection
        // moves release to BlockRecords Release Collection
        pub fun createAndAddRelease(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: UInt64,
            payouts: [BlockRecords.Payout]
        ): UInt64 {
            pre {
                // receiverCollection.check() == true : "receiver collection should exist"
                // todo: verify that payout vaults exist
            }

            let release <- create Release(
                type: type,
                name: name, 
                literation: literation, 
                image: image, 
                audio: audio,
                copiesCount: copiesCount,
                payouts: payouts,
                releaseCollectionID: self.id
            )

            let id = release.id

            // add release to release collection dictionary
            let oldRelease <- self.releases[id] <- release
            destroy oldRelease

            return id
        }

        pub fun getID(): UInt64 {
            return self.id
        }

        pub fun getName(): String {
            return self.name
        }
        
        pub fun getDescription(): String {
            return self.description
        }
        
        pub fun getLogo(): String {
            return self.logo
        }
        
        pub fun getBanner(): String {
            return self.banner
        }

        pub fun getWebsite(): String {
            return self.website
        }

        pub fun getSocialMedias(): [String] {
            return self.socialMedias
        }

        pub fun borrowReleases(): [&Release] {
            let releases: [&Release] = []
            let keys = self.releases.keys
            for key in keys {
                let release = &self.releases[key] as &Release
                releases.append(release)
            }

            return releases
        }

        pub fun borrowReleaseByID(_ id: UInt64): &Release {
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
        name: String,
        description: String,
        logo: String,
        banner: String,
        website: String,
        socialMedias: [String]
    ): @Collection {
        return <- create Collection(
            name: name,
            description: description,
            logo: logo,
            banner: banner,
            website: website,
            socialMedias: socialMedias
        )
    }

    pub resource interface ReleasePublic {
        pub fun getID(): UInt64
        pub fun getNFTIDs(): [UInt64]
        pub fun getMetadata(): {String: AnyStruct}
        pub fun getReleaseType(): String
        pub fun getIsComplete(): Bool
    }

    // acts as the root resource for any NFT minted by a creator
    // all singles, albums, etc... must be associated with a release
    pub resource Release: ReleasePublic {
        // unique id of the release
        pub let id: UInt64

        // metadata of the release
        // this metadata is almost identical - only lacking serial number & release ID - to
        // the metadata of nfts associated with this release.
        // much like the stamp used to print a pokemon card
        pub let metadata: {String: AnyStruct}

        // "type" of release
        pub let type: String

        // NFT copies count
        pub let copiesCount: UInt64

        // ids of nfts associated with release
        pub let nftIDs: [UInt64]

        pub let releaseCollectionID: UInt64

        // checks if nfts were minted for the release
        pub var isComplete: Bool

        init(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: UInt64,
            payouts: [BlockRecords.Payout],
            releaseCollectionID: UInt64
        ){
            pre{
                type == "single" : "release type invalid"
                payouts.length > 0 : "at least one payout is required"
                copiesCount > 0 : "number of copies must be greater than 0"
            }

            self.id = BlockRecordsRelease.totalSupply
            self.type = type
            self.copiesCount = copiesCount
            self.nftIDs = []
            self.isComplete = false
            self.releaseCollectionID = releaseCollectionID

            self.metadata = {
                "name": name,
                "literation": literation,
                "image": image,
                "audio": audio,
                "payouts": payouts
            }

            emit Created(id: self.id, metadata:{
                "name": name,
                "literation": literation,
                "image": image,
                "audio": audio,
                "copies_count": copiesCount.toString()
            })

            // iterate supply
            BlockRecordsRelease.totalSupply = BlockRecordsRelease.totalSupply + (1 as UInt64)
        }

        pub fun getID(): UInt64 {
            return self.id
        }

        pub fun getNFTIDs(): [UInt64] {
            return self.nftIDs
        }

        pub fun getMetadata(): {String: AnyStruct} {
            return self.metadata
        }
        
        // "getReleaseType" because getType is already a function in cadence
        pub fun getReleaseType(): String {
            return self.type
        }

        pub fun getIsComplete(): Bool {
            return self.isComplete
        }

        // create and deposit nfts to isComplete release
        pub fun mintSingles(receiverCollection: &{NonFungibleToken.CollectionPublic}) {    
            pre {
                // todo: this is pretty verbose
                self.type == "single" : "release is not of type single"
                self.metadata["name"]!.getType() == Type<String>() : "metadata field type missmatch or missing value for field: name"
                self.metadata["literation"]!.getType() == Type<String>()  : "metadata field type missmatch or missing value for field: name"
                self.metadata["image"]!.getType() == Type<String>()  : "metadata field type missmatch or missing value for field: name"
                self.metadata["audio"]!.getType() == Type<String>()  : "metadata field type missmatch or missing value for field: name"
                // todo: check if payouts are valid
                // todo: check if receiver collection is valid
            }
            
            let name: String = self.metadata["name"]! as! String
            let literation: String = self.metadata["literation"]! as! String
            let image: String = self.metadata["image"]! as! String
            let audio: String = self.metadata["audio"]! as! String
            let payouts: [BlockRecords.Payout] = self.metadata["payouts"] as! [BlockRecords.Payout]
            var serialNumber: UInt64 = 1
            
            while serialNumber <= self.copiesCount {
                let single <- BlockRecordsSingle.mint(
                    name: name, 
                    literation: literation, 
                    image: image, 
                    audio: audio,
                    serialNumber: serialNumber,
                    releaseID: self.id,
                    payouts: payouts
                )

                // append id to release collection
                self.nftIDs.append(single.id)

                // deposit into specified collection
                receiverCollection.deposit(
                    token: <- single
                )

                // increment serial number
                serialNumber = serialNumber + 1
            }

            self.isComplete = true
        }

        // pub fun mintAlbums
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

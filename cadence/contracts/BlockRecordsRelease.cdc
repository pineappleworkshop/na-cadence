
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS

/** 

## Releases are the root resource of any BlockRecords nft.

potential "creators" will create and save the creator resource to their storage and expose
its capability receiver function publicly. this allows the service account to create a unique
Collection, save it to storage, create a private capability, and send that capability 
to the creator. the service account maintains the right to revoke this capability - blocking the
creator's access to their release collection - in the event that the creator violates our terms
and agreements.

**/

pub contract BlockRecordsRelease {

    pub event ContractInitialized()
    pub event Created(id: UInt64, metadata: {String: String})    
    pub event CollectionCreated(
        id: UInt64,
        name: String,
        description: String,
        logo: String,
        banner: String,
        socialMedias: [String]
    )

    pub let CreatorStoragePath: StoragePath
    pub let CreatorPublicPath: PublicPath
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    
    // the total number of Release Collections and Releases that have been created
    access(contract) var totalSupply: UInt64

    pub resource interface CollectionOwner {
        pub fun setName(_ val: String) {
            pre {
                val.length <= 16: "name must be 30 or less characters"
            }
        }
        pub fun setDescription(_ val: String) {
            pre {
                val.length <= 255: "description must be 255 characters or less"
            }
        }
        pub fun setLogo(_ val: String){
            pre {
                val.length <= 255: "logo must be 255 characters or less"
            }
        }
        pub fun setBanner(_ val: String){
            pre {
                val.length <= 255: "logo must be 255 characters or less"
            }
        }
        pub fun setWebsite(_ val: String){
            pre {
                val.length <= 255: "logo must be 255 characters or less"
            }
        }
        // todo:
        // pub fun getSocialMedias(_ val: [String])  {
        //     pre {
        //         BlockRecordsUser.verifyTags(tags: val, tagLength:10, tagSize:3) : "cannot have more then 3 tags of length 10"
        //     }
        // }   
        pub fun borrowRelease(id: UInt64): &Release
        pub fun createAndAddRelease(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: Int,
            payouts: [BlockRecords.Payout]
        ): UInt64 
    }

    pub resource interface CollectionPublic {
        pub fun getID(): UInt64
        pub fun getName(): String
        pub fun getDescription(): String
        pub fun getLogo(): String
        pub fun getBanner(): String
        pub fun getWebsite(): String
        pub fun getSocialMedias(): [String]
        pub fun getReleaseIDs(): [UInt64]
        pub fun borrowReleasePublic(id: UInt64): &Release{ReleasePublic}
    }

    // any account in posession of a Collection will be able to mint BlockRecords NFTs
    // this is secure because "transactions cannot create resource types outside of containing contracts"
    pub resource Collection: CollectionPublic, CollectionOwner {  
        // unique id of the release collection
        pub let id: UInt64

        // name of the release collection
        access(self) var name: String
        
        // description of the release collection
        access(self) var description: String

        // logo image will be used for featuring your collection on the homepage, category pages, etc...
        // 600 x 400 recommended
        access(self) var logo: String

        // banner image will appear at the top of your collection page
        // 1400 x 1400 recommended
        access(self) var banner: String

        // url of promotional website
        access(self) var website: String

        // social media urls
        access(self) var socialMedias: [String]

        // dictionary of releases in the collection
        access(self) var releases: @{UInt64: Release}

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

            emit CollectionCreated(
                id: self.id,
                name: name,
                description: description,
                logo: logo,
                banner: banner,
                socialMedias: socialMedias
            )

            // iterate supply
            BlockRecordsRelease.totalSupply = BlockRecordsRelease.totalSupply + (1 as UInt64)
        }

        pub fun createAndAddRelease(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: Int,
            payouts: [BlockRecords.Payout]
        ): UInt64 {

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

        pub fun getReleaseIDs(): [UInt64] {
            return self.releases.keys
        }

        pub fun setName(_ val: String) { 
            self.name = val 
        }

         pub fun setDescription(_ val: String) { 
            self.description = val
        }

        pub fun setLogo(_ val: String) { 
            self.logo = val
        }
        
        pub fun setBanner(_ val: String) { 
            self.banner = val 
        }

        pub fun setWebsite(_ val: String) { 
            self.website = val 
        }

        pub fun borrowRelease(id: UInt64): &Release {
            pre {
                self.releases[id] != nil : "release doesn't exist"
            }
            return &self.releases[id] as &Release
        }

        pub fun borrowReleasePublic(id: UInt64): &Release{ReleasePublic} {
            pre {
                self.releases[id] != nil : "release doesn't exist"
            }
            return &self.releases[id] as &Release{ReleasePublic}
        }

        destroy(){
            destroy self.releases
        }
    }

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
        pub let id: UInt64
        pub fun getNFTIDs(): [UInt64]
        pub fun getMetadata(): {String: AnyStruct}
        pub let type: String
        pub fun getIsComplete(): Bool
    }

    // The Release resource acts as the root resource for any NFT minted by a creator
    // all singles, albums, etc... must be associated with a release
    pub resource Release: ReleasePublic {
        // unique id of the release
        pub let id: UInt64

        // metadata of the release
        // this metadata is almost identical - only lacking serial number & release ID - to
        // the metadata of nfts associated with this release.
        // much like the stamp used to print a pokemon card
        access(self) let metadata: {String: AnyStruct}

        // "type" of release
        pub let type: String

        // NFT copies count
        pub let copiesCount: Int

        // ids of nfts associated with release
        access(self) var nftIDs: [UInt64]

        // the id of the release collection that the release belongs to
        pub let releaseCollectionID: UInt64

        // checks if nfts were minted for the release
        access(self) var isComplete: Bool

        init(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: Int,
            payouts: [BlockRecords.Payout],
            releaseCollectionID: UInt64
        ){
            pre {
                type == "single" : "release type invalid" // only singles for now
                name.length <= 30: "name must be 30 or less characters"
                literation.length <= 10000: "description must be 10,000 characters or less"
                image.length <= 255: "description must be 255 characters or less"
                audio.length <= 255: "description must be 255 characters or less"
                image.length <= 255: "description must be 255 characters or less"
                copiesCount <= 10000: "total copies count must be 10,000 or less"
                // todo: validate all payout receivers exist
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

        // it might be necessary to call this function multiple times to complete a release -
        // depending on how many nfts exist in the release
        pub fun mintSingles(count: Int, receiverCollection: &{NonFungibleToken.CollectionPublic}) {    
            pre {
                self.isComplete == false : "release is complete"
                self.nftIDs.length + count <= self.copiesCount : "mint would exceed release copies count"
            }
            
            // map metadata to single
            let name: String = self.metadata["name"]! as! String
            let literation: String = self.metadata["literation"]! as! String
            let image: String = self.metadata["image"]! as! String
            let audio: String = self.metadata["audio"]! as! String
            let payouts: [BlockRecords.Payout] = [] as! [BlockRecords.Payout]

            var i = 1
            while i <= count {
                let single <- BlockRecordsSingle.mint(
                    name: name, 
                    literation: literation, 
                    image: image, 
                    audio: audio,
                    serialNumber: self.nftIDs.length,
                    releaseID: self.id,
                    payouts: payouts
                )

                // append id to release collection
                self.nftIDs.append(single.id)

                // deposit into specified collection
                receiverCollection.deposit(
                    token: <- single
                )

                // release is complete when the nft count and copiesCount are equal
                if self.nftIDs.length == self.copiesCount {
                    self.isComplete = true
                    break
                }

                // increment counter
                i = i + 1
            }
        }

        // todo: pub fun mintAlbums
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

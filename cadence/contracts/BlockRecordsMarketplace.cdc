
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsStorefront from 0xSERVICE_ACCOUNT_ADDRESS

/**

Marketplaces are storefronts for BlockRecords service accounts.

potential "admins" will create and save the admin resource to their storage and expose
its capability receiver function publicly. this allows the service account to create a unique
Marketplace, and send a marketplace capability to the admin. the service account maintains the right to revoke 
this capability - blocking the admin's access to the marketplace - in the event that the admin violates our terms and agreements.

**/

pub contract BlockRecordsMarketplace {

    //events
    //
    pub event ContractInitialized()
    
    pub event MarketplaceCreated(
        id: UInt64,
        name: String
        // todo: payout info
    )
    
    pub event MarketplaceDestroyed(
        id: UInt64,
        name: String
    )

    // named paths
    //
    pub let MarketplaceStoragePath: StoragePath
    pub let MarketplacePublicPath: PublicPath
    pub let MarketplacePrivatePath: PrivatePath

    pub let AdminPrivatePath: PrivatePath
    pub let AdminStoragePath: StoragePath

    // the total number of BlockRecordsMarketplaces that have been created
    //
    pub var totalSupply: UInt64

    pub resource interface MarketplacePublic {
        pub fun getID(): UInt64
        pub fun getName(): String
        pub fun getPayout(): BlockRecords.Payout
        // pub fun getReleaseCollectionIDs(): [UInt64]
        // pub fun getStorefrontIDs(): [UInt64]
        // pub fun borrowReleaseCollectionByID(_ id: UInt64): &BlockRecordsRelease.Collection
        pub fun listStorefront(storefrontCapability: Capability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>)
        pub fun purchaseListingFromStorefront(listingID: UInt64, storefrontID: UInt64, payment: @FungibleToken.Vault): @NonFungibleToken.NFT
        // todo: get storefront ids
        // todo: borrow storefront by id
        // todo: etc...
    }

    // any account in posession of a Marketplace capability will be able to create release collections
    // 
    pub resource Marketplace: MarketplacePublic {  
        // id of the marketplace
        pub let id: UInt64

        // name of the marketplace
        pub let name: String

        // sale fee cut of the marketplace
        pub let payout: BlockRecords.Payout

        // service account can create a capability to this release collection
        // then give cap to user so that they can create releases.
        // note: this capability is revokable
        // pub var releaseCollections: @{UInt64: BlockRecordsRelease.Collection}
        pub var releaseCollections: {Address: Capability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionPublic}>}

        // todo (maybe): we can store references to users' storefronts
        // so that we can list the sales in a central place
        pub var storefronts: {UInt64: Capability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>}

        init(
            name: String,
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64
        ){
            self.id = BlockRecordsSingle.totalSupply
            self.name = name
            self.releaseCollections = {}
            self.storefronts = {}

            self.payout = BlockRecords.Payout(
                fusdVault: fusdVault,
                percentFee: percentFee
            )

            // todo: emit marketplace created

            // increment id
            BlockRecordsMarketplace.totalSupply = BlockRecordsMarketplace.totalSupply + (1 as UInt64)
        }

        pub fun getID(): UInt64 {
            return self.id
        }

        pub fun getName(): String {
            return self.name
        }

        pub fun getPayout(): BlockRecords.Payout {
            return self.payout
        }

        pub fun addReleaseCollection(releaseCollectionCapability: Capability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionPublic}>, address: Address) {
            self.releaseCollections[address] = releaseCollectionCapability
            // todo (maybe): emit event
        }

        // create release collection and add to release collection resource dictionary
        // releases and their collections are to be stored in the marketplace rather than 
        // in user accounts. this helps us maintain some level of control as to who is able
        // to create on our platform
        // pub fun createAndAddReleaseCollection(
        //     name: String,
        //     description: String,
        //     logo: String,
        //     banner: String,
        //     website: String,
        //     socialMedias: [String]
        // ): UInt64 {
        //     let releaseCollection <- BlockRecordsRelease.createReleaseCollection(
        //         name: name,
        //         description: description,
        //         logo: logo,
        //         banner: banner,
        //         website: website,
        //         socialMedias: socialMedias
        //     )

        //     let id = releaseCollection.id

        //     // add release to release collection dictionary
        //     let oldRC <- self.releaseCollections[id] <- releaseCollection
        //     destroy oldRC

        //     return id
        // }

        // get all release collection ids
        // pub fun getReleaseCollectionIDs(): [UInt64] {
        //     return self.releaseCollections.keys
        // }

        // // borrow release collection by id
        // pub fun borrowReleaseCollectionByID(_ id: UInt64): &BlockRecordsRelease.Collection {
        //     pre {
        //         self.releaseCollections[id] != nil : "release collection doesn't exist"
        //     }
        //     return &self.releaseCollections[id] as &BlockRecordsRelease.Collection
        // }

        // get all storefront ids
        pub fun getStorefrontIDs(): [UInt64] {
            return self.storefronts.keys
        }

        // users can list their storefronts so that they are viewable in the marketplace
        pub fun listStorefront(storefrontCapability: Capability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>) {
            pre {
                storefrontCapability.check() : "invalid storefront capability"
            }
            let storefront = storefrontCapability.borrow()!
            self.storefronts[storefront.uuid] = storefrontCapability

            // todo: emit storefront listed
        }

        // users can purchase listings from a storefront in the marketplace.
        // payouts are distributed to the marketplace accordingly
        // NOTE: a user can circumvent this marketplace payout by writing their own transaction
        // to purchase a listing from a user directly. we are OK with this!
        pub fun purchaseListingFromStorefront(listingID: UInt64, storefrontID: UInt64, payment: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.storefronts[storefrontID] != nil: "could not find storefront with given id"
                self.payout.receiver.check() : "could not get marketplace payout receiver"
            }
            let storefront = self.storefronts[storefrontID]!.borrow()!
            let listing = storefront.borrowListing(listingResourceID: listingID)!
            let listingDetails = listing.getDetails()

            // distribute payout to the marketplace
            let receiver = self.payout.receiver.borrow()!
            let p <- payment.withdraw(amount: self.payout.percentFee * listingDetails.price)
            receiver.deposit(from: <-p)

            // return nft to the buyer
            let nft <- storefront.purchaseListing(listingResourceID: listingID, payment: <- payment)
            return <- nft
        }
    }

    pub resource interface AdminPublic {
          pub fun addCapability(cap: Capability<&Marketplace>)
    }

    // accounts can create creator resource but will need to be authorized
    pub fun createAdmin(): @Admin {
          return <- create Admin()
    }

    // resource that an admin would own to be a marketplace admin
    // should this be moved to BlockRecordsUser?
    // 
    pub resource Admin: AdminPublic {
        //ownership of this capability allows for the creation of Release Collections
        access(account) var marketplaceCapability: Capability<&Marketplace>?

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
            name: String,
            description: String,
            logo: String,
            banner: String,
            website: String,
            socialMedias: [String]
        ): @BlockRecordsRelease.Collection {
             pre {
                self.marketplaceCapability != nil: "not an authorized admin"
            }
            return <- BlockRecordsRelease.createReleaseCollection(
                name: name,
                description: description,
                logo: logo,
                banner: banner,
                website: website,
                socialMedias: socialMedias
            )
        }
    }

    // pub fun borrowReleaseCollection(id: UInt64): @BlockRecordsRelease.Collection {
    //     return self.releaseCollections[id]
    // }

    init() {
        self.totalSupply = 0

        self.MarketplaceStoragePath = /storage/BlockRecordsMarketplace
        self.MarketplacePublicPath = /public/BlockRecordsMarketplace
        self.MarketplacePrivatePath = /private/BlockRecordsMarketplace
        
        self.AdminPrivatePath = /private/BlockRecordsAdmin
        self.AdminStoragePath = /storage/BlockRecordsAdmin

        // marketplaces require FUSD vaults to receive their payouts
        // (we assume that the service account has not initialized an FUSD vault yet) 
        let fusdVaultStoragePath = /storage/FUSDVault
        let fusdVaultReceiverPublicPath = /public/FUSDVaultReceiver
        let fusdVaultBalancePublicPath = /public/FUSDVaultBalance
        self.account.save(<- FUSD.createEmptyVault(), to: fusdVaultStoragePath)
        self.account.link<&FUSD.Vault{FungibleToken.Receiver}>(
            fusdVaultReceiverPublicPath,
            target: fusdVaultStoragePath
        )
        self.account.link<&FUSD.Vault{FungibleToken.Balance}>(
            fusdVaultBalancePublicPath,
            target: fusdVaultStoragePath
        )

        // initialize and save marketplace resource to account storage
        let marketplaceFUSDVault = self.account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(fusdVaultReceiverPublicPath)!
        let marketplace <- create Marketplace(
            name: "Block Records",
            fusdVault: marketplaceFUSDVault,
            percentFee: 0.05
        )
        self.account.save(<- marketplace, to: self.MarketplaceStoragePath)
        self.account.link<&BlockRecordsMarketplace.Marketplace>(
            self.MarketplacePrivatePath,
            target: self.MarketplaceStoragePath
        )

        self.account.link<&BlockRecordsMarketplace.Marketplace{BlockRecordsMarketplace.MarketplacePublic}>(
            self.MarketplacePublicPath,
            target: self.MarketplaceStoragePath
        )       
        
        // for simplicity, let's make the service account an admin
        let marketplaceCap = self.account.getCapability<&BlockRecordsMarketplace.Marketplace>(self.MarketplacePrivatePath)!
        let admin <- create Admin()
        admin.addCapability(cap: marketplaceCap)
        self.account.save(<- admin, to: self.AdminStoragePath)
        self.account.link<&BlockRecordsMarketplace.Admin>(self.AdminPrivatePath, target: self.AdminStoragePath)  

        emit ContractInitialized()
    }
}


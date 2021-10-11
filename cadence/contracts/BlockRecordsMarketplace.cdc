
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsStorefront from 0xSERVICE_ACCOUNT_ADDRESS

/**

The BlockRecordsMarketplace acts as a central facilitator for the BlockRecords platform.
    
    // Release Collections
    //
        release collections and releases are stored centrally in the service account so that BlockRecords admins can arbitrate who is able to mint on the platform. 
        when a new creator is onboarded onto the platform, a new release collection will be created for them and a capability will be given to their UserProfile; allowing the creator to create new releases and mint nfts
        capabilities to release collections - stored in the marketplace - allow users to view verified creators' release collections and releases. 
     
    // Storefronts
    //
        users can list their storefront on the marketplace by giving a public capability to the marketplace
        capabilities to storefronts  - stored in the marketplace - allow users to view what others have for sale, purchase listings, and put their own listings up for sale on the marketplace. in exchange for this ease of use,
        the marketplace takes a small percentage fee on every transaction.
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
        pub fun getReleaseCollectionAddresses(): [Address]
        pub fun borrowReleaseCollection(address: Address): &BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionPublic}
        pub fun borrowStorefront(address: Address): &BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}
        pub fun getStorefrontAddresses(): [Address]
        pub fun listStorefront(storefrontCapability: Capability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>, address: Address)
        pub fun purchaseListingFromStorefront(listingID: UInt64, storefrontAddress: Address, payment: @FungibleToken.Vault): @NonFungibleToken.NFT
        pub fun borrowListingFromStorefront(listingID: UInt64, storefrontAddress: Address): &BlockRecordsStorefront.Listing{BlockRecordsStorefront.ListingPublic}
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
        access(self) var releaseCollections: {Address: Capability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionPublic}>}

        // todo (maybe): we can store references to users' storefronts
        // so that we can list the sales in a central place
        access(self) var storefronts: {Address: Capability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>}

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

        // get all release collection addresses
        pub fun getReleaseCollectionAddresses(): [Address] {
            return self.releaseCollections.keys
        }

       pub fun borrowReleaseCollection(address: Address): &BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionPublic} {
           pre {
                self.releaseCollections[address] != nil : "release collection not found"
            }
            return self.releaseCollections[address]!.borrow()!
       }

        // get all storefront addresses
        pub fun getStorefrontAddresses(): [Address] {
            return self.storefronts.keys
        }

        // borrow storefront by address
        pub fun borrowStorefront(address: Address): &BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic} {
            pre {
                self.storefronts[address] != nil : "storefront is unlisted or doesn't exist"
            }
            return self.storefronts[address]!.borrow()!
        }

        pub fun borrowListingFromStorefront(
            listingID: UInt64, 
            storefrontAddress: Address
        ): &BlockRecordsStorefront.Listing{BlockRecordsStorefront.ListingPublic} {
            pre {
                self.storefronts[storefrontAddress] != nil : "storefront is unlisted or doesn't exist"
            }
            let storefront = self.borrowStorefront(address: storefrontAddress)
            let listing = storefront.borrowListing(listingResourceID: listingID)!
            return listing
        }

        // users can list their storefronts so that they are viewable in the marketplace
        // NOTE: malicious users might set address as a different address than their own
        // there's probably a better way to do this...
        pub fun listStorefront(
            storefrontCapability: Capability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>,
            address: Address
        ) {
            pre {
                storefrontCapability.check() : "invalid storefront capability"
            }
            let storefront = storefrontCapability.borrow()!
            self.storefronts[address] = storefrontCapability

            // todo: emit storefront listed
        }

        // users can purchase listings from a storefront in the marketplace.
        // payouts are distributed to the marketplace accordingly
        // NOTE: a user can circumvent this marketplace payout by writing their own transaction
        // to purchase a listing from a user directly. we are OK with this!
        pub fun purchaseListingFromStorefront(
            listingID: UInt64, 
            storefrontAddress: Address, 
            payment: @FungibleToken.Vault
        ): @NonFungibleToken.NFT {
            pre {
                self.storefronts[storefrontAddress] != nil: "could not find storefront with given id"
                self.payout.receiver.check() : "could not get marketplace payout receiver"
            }
            let storefront = self.storefronts[storefrontAddress]!.borrow()!
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


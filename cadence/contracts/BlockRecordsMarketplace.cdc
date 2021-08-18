
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS

/**

Marketplaces are storefronts for BlockRecords service accounts.

potential "admins" will create and save the admin resource to their storage and expose
its capability receiver function publicly. this allows the service account to create a unique
Marketplace, and send that capability to the admin. the service account maintains the right to revoke this capability - blocking the
admin's access to the marketplace - in the event that the admin violates our terms and agreements.

**/

pub contract BlockRecordsMarketplace {

    //events
    //
    pub event ContractInitialized()
    pub event Event(type: String, metadata: {String: String})

    // named paths
    //
    pub let MarketplaceStoragePath: StoragePath
    pub let MarketplacePublicPath: PublicPath
    pub let MarketplacePrivatePath: PrivatePath

    pub let AdminPrivatePath: PrivatePath
    pub let AdminStoragePath: StoragePath

    pub resource interface MarketplacePublic {
        pub let name: String
        pub let payout: Payout
        pub fun borrowReleaseCollections(): [&BlockRecordsRelease.ReleaseCollection]
        pub fun borrowReleaseCollectionByProfileAddress(_ address: Address): &BlockRecordsRelease.ReleaseCollection
        pub fun borrowReleaseByNFTID(_ nftID: UInt64): &BlockRecordsRelease.Release
    }

    // any account in posession of a Marketplace capability will be able to create release collections
    // 
    pub resource Marketplace: MarketplacePublic {  

        // name of the marketplace
        pub let name: String

        // the sale fee cut of the marketplace
        pub let payout: Payout

        // todo: change this to dict
        access(account) var releaseCollectionCapabilities: [Capability<&BlockRecordsRelease.ReleaseCollection>]

        init(
            name: String,
            fusdVault: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64
        ){
            self.name = name

            self.payout = Payout(
                fusdVault: fusdVault,
                percentFee: percentFee
            )

            self.releaseCollectionCapabilities = []
        }

        pub fun addReleaseCollectionCapability(cap: Capability<&BlockRecordsRelease.ReleaseCollection>) {
            self.releaseCollectionCapabilities.append(cap)
        }

        pub fun borrowReleaseCollections(): [&BlockRecordsRelease.ReleaseCollection] {
            let releaseCollections: [&BlockRecordsRelease.ReleaseCollection] = []
            for rc in self.releaseCollectionCapabilities {
                let releaseCollection = rc!.borrow()!
                releaseCollections.append(releaseCollection)
            }
            return releaseCollections as [&BlockRecordsRelease.ReleaseCollection]
        }

        // borrow release collection by creator profile address
        pub fun borrowReleaseCollectionByProfileAddress(_ address: Address) : &BlockRecordsRelease.ReleaseCollection {
            var releaseCollection: &BlockRecordsRelease.ReleaseCollection? = nil
            let releaseCollections = self.borrowReleaseCollections()
            for rc in releaseCollections {
                if rc.creatorProfile.address == address {
                    releaseCollection = rc as &BlockRecordsRelease.ReleaseCollection
                    break
                }
            }
            return releaseCollection! as &BlockRecordsRelease.ReleaseCollection
        }

        // borrow release by nft id
        pub fun borrowReleaseByNFTID(_ nftID: UInt64) : &BlockRecordsRelease.Release {
            var releaseCollection: &BlockRecordsRelease.ReleaseCollection? = nil
            var release: &BlockRecordsRelease.Release? = nil
            let releaseCollections = self.borrowReleaseCollections()
            for rc in releaseCollections {
                for key in rc.releases.keys {
                    let r: &BlockRecordsRelease.Release = &rc.releases[key] as &BlockRecordsRelease.Release
                    if r.nftIDs.contains(nftID) {
                        release = r as &BlockRecordsRelease.Release
                        break
                    }
                }
            }
            return release! as &BlockRecordsRelease.Release
        }
    }

    pub resource interface AdminPublic {
          pub fun addCapability(cap: Capability<&Marketplace>)
    }

    // accounts can create creator resource but will need to be authorized
    pub fun createAdmin(): @Admin {
          return <- create Admin()
    }

    // resource that an admin would own to be able to create BlockRecordsRelease.Release Collections
    // 
    pub resource Admin: AdminPublic {

        //ownership of this capability allows for the creation of BlockRecordsRelease.Release Collections
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
            creatorStageName: String,
            creatorLegalName: String,
            creatorImageURL: String,
            creatorAddress: Address
        ): @BlockRecordsRelease.ReleaseCollection {
        return <- BlockRecordsRelease.createReleaseCollection(
            creatorStageName: creatorStageName,
            creatorLegalName: creatorLegalName,
            creatorImageURL: creatorImageURL,
            creatorAddress: creatorAddress
        )}
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
        self.MarketplaceStoragePath = /storage/BlockRecordsMarketplace
        self.MarketplacePublicPath = /public/BlockRecordsMarketplace
        self.MarketplacePrivatePath = /private/BlockRecordsMarketplace
        
        self.AdminPrivatePath = /private/BlockRecordsAdmin
        self.AdminStoragePath = /storage/BlockRecordsAdmin

        // initialize FUSD vault for service account so that we can receive sale percentFees and check balance
        self.account.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
        self.account.link<&FUSD.Vault{FungibleToken.Receiver}>(
            /public/fusdReceiver,
            target: /storage/fusdVault
        )
        self.account.link<&FUSD.Vault{FungibleToken.Balance}>(
            /public/fusdBalance,
            target: /storage/fusdVault
        )

        // initialize and save marketplace resource to account storage
        let marketplaceFUSDVault = self.account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
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

        // todo: store public interface private?
        self.account.link<&BlockRecordsMarketplace.Marketplace{BlockRecordsMarketplace.MarketplacePublic}>(
            self.MarketplacePublicPath,
            target: self.MarketplaceStoragePath
        )       

        // add marketplace capability to admin resource
        let marketplaceCap = self.account.getCapability<&BlockRecordsMarketplace.Marketplace>(self.MarketplacePrivatePath)!
        
        // initialize and save admin resource
        let admin <- create Admin()
        admin.addCapability(cap: marketplaceCap)
        self.account.save(<- admin, to: self.AdminStoragePath)
        self.account.link<&BlockRecordsMarketplace.Admin>(self.AdminPrivatePath, target: self.AdminStoragePath)  

        emit ContractInitialized()
    }
}


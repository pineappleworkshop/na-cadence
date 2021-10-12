
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

/* 

## Storefronts facilitate sales for BlockRecords users (collectors and creators).

Buyers can purchase these NFTs for sale by providing a capability to an FUSD vault
with a sufficient balance. On each sale, payouts will be distributed to the NFT's designated parties.

*/

pub contract BlockRecordsStorefront {

    pub let StorefrontStoragePath: StoragePath
    pub let StorefrontPublicPath: PublicPath
    pub let StorefrontManagerPath: PrivatePath
    pub let StorefrontMarketplacePath: PrivatePath

    pub event ContractInitialized()
    pub event StorefrontInitialized(storefrontResourceID: UInt64)
    pub event StorefrontDestroyed(storefrontResourceID: UInt64)
    pub event ListingAvailable(
        storefrontAddress: Address,
        listingResourceID: UInt64,
        nftID: UInt64,
        price: UFix64
    )
    pub event ListingCompleted(
        listingResourceID: UInt64, 
        storefrontResourceID: UInt64, 
        purchased: Bool
    )

    // StorefrontManager
    // An interface for adding and removing Listings within a Storefront,
    // intended for use by the Storefront's own
    //
    pub resource interface StorefrontManager {
        // createListing
        // Allows the Storefront owner to create and insert Listings.
        //
        pub fun createListing(
            nftProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.CollectionPublic, NonFungibleToken.Provider}>,
            nftID: UInt64,
            paymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>,
            price: UFix64
        ): UInt64
        
        // removeListing
        // Allows the Storefront owner to remove any sale listing, acepted or not.
        //
        pub fun removeListing(listingResourceID: UInt64)
    }

    // StorefrontMarketplace
    // An interface to allow listing and borrowing Listings, and purchasing items via Listings
    // in a Storefront.
    //
    pub resource interface StorefrontMarketplace {
        pub fun getListingIDs(): [UInt64]
        pub fun borrowListingFromMarketplace(listingResourceID: UInt64): &Listing{ListingMarketplace}?
        pub fun purchaseListingFromMarketplace(
            listingResourceID: UInt64, 
            payment: @FungibleToken.Vault, 
            marketplaceFee: UFix64
        ): @NonFungibleToken.NFT
        pub fun cleanup(listingResourceID: UInt64)
   }


    // StorefrontPublic
    // An interface to allow listing and borrowing Listings, and purchasing items via Listings
    // in a Storefront.
    //
    pub resource interface StorefrontPublic {
        pub fun getListingIDs(): [UInt64]
        pub fun borrowListing(listingResourceID: UInt64): &Listing{ListingPublic}?
        pub fun purchaseListing(listingResourceID: UInt64, payment: @FungibleToken.Vault): @NonFungibleToken.NFT
        pub fun cleanup(listingResourceID: UInt64)
   }

    // Storefront
    // A resource that allows its owner to manage a list of Listings, and anyone to interact with them
    // in order to query their details and purchase the NFTs that they represent.
    //
    pub resource Storefront : StorefrontManager, StorefrontPublic, StorefrontMarketplace {
        // The dictionary of Listing uuids to Listing resources.
        access(self) var listings: @{UInt64: Listing}
        
        // constructor
        //
        init () {
            self.listings <- {}

            // Let event consumers know that this storefront exists
            emit StorefrontInitialized(storefrontResourceID: self.uuid)
        }

        // insert
        // Create and publish a Listing for an NFT.
        //
         pub fun createListing(
            nftProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.CollectionPublic, NonFungibleToken.Provider}>,
            nftID: UInt64,
            paymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>,
            price: UFix64
         ): UInt64 {
            let listing <- create Listing(
                nftProvider: nftProvider,
                nftID: nftID,
                paymentReceiver: paymentReceiver,
                price: price,
                storefrontID: self.uuid
            )

            let listingResourceID = listing.uuid
            let listingPrice = listing.getDetails().price

            // Add the new listing to the dictionary.
            // Note that oldListing will always be nil, but we have to handle it.
            let oldListing <- self.listings[listingResourceID] <- listing
            destroy oldListing

            emit ListingAvailable(
                storefrontAddress: self.owner?.address!,
                listingResourceID: listingResourceID,
                nftID: nftID,
                price: listingPrice
            )

            return listingResourceID
        }

        // removeListing
        // Remove a Listing that has not yet been purchased from the collection and destroy it.
        //
        pub fun removeListing(listingResourceID: UInt64) {
            let listing <- self.listings.remove(key: listingResourceID)
                ?? panic("missing Listing")
    
            // This will emit a ListingCompleted event.
            destroy listing
        }

        // getListingIDs
        // Returns an array of the Listing resource IDs that are in the collection
        //
        pub fun getListingIDs(): [UInt64] {
            return self.listings.keys
        }

        // borrowSaleItem
        // Returns a read-only view of the SaleItem for the given listingID if it is contained by this collection.
        //
        pub fun borrowListing(listingResourceID: UInt64): &Listing{ListingPublic}? {
            if self.listings[listingResourceID] != nil {
                return &self.listings[listingResourceID] as! &Listing{ListingPublic}
            } else {
                return nil
            }
        }

        // borrow listing from marketplace
        // Returns a read-only view of the SaleItem for the given listingID if it is contained by this collection.
        //
        pub fun borrowListingFromMarketplace(listingResourceID: UInt64): &Listing{ListingMarketplace}? {
            if self.listings[listingResourceID] != nil {
                return &self.listings[listingResourceID] as! &Listing{ListingMarketplace}
            } else {
                return nil
            }
        }

        pub fun purchaseListing(listingResourceID: UInt64, payment: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.listings[listingResourceID] != nil: "could not find listing with given id"
            }
            let listing = self.borrowListing(listingResourceID: listingResourceID)!
            let nft <- listing.purchase(payment: <- payment)
            return <- nft
        }

        pub fun purchaseListingFromMarketplace(listingResourceID: UInt64, payment: @FungibleToken.Vault, marketplaceFee: UFix64): @NonFungibleToken.NFT {
            pre {
                self.listings[listingResourceID] != nil: "could not find listing with given id"
            }
            let listing = self.borrowListingFromMarketplace(listingResourceID: listingResourceID)!
            let nft <- listing.purchaseFromMarketplace(payment: <- payment, marketplaceFee: marketplaceFee)
            return <- nft
        }

        // cleanup
        // Remove an listing *if* it has been purchased.
        // Anyone can call, but at present it only benefits the account owner to do so.
        // Kind purchasers can however call it if they like.
        //
        pub fun cleanup(listingResourceID: UInt64) {
            pre {
                self.listings[listingResourceID] != nil: "could not find listing with given id"
            }

            let listing <- self.listings.remove(key: listingResourceID)!
            assert(listing.getDetails().purchased == true, message: "listing is not purchased, only admin can remove")
            destroy listing
        }

        // destructor
        //
        destroy () {
            destroy self.listings

            // Let event consumers know that this storefront will no longer exist
            emit StorefrontDestroyed(storefrontResourceID: self.uuid)
        }
    }

    // any user can call this to create a storefront for their BlockRecords NFTs
    pub fun createStorefront(): @Storefront {
        return <-create Storefront()
    }

    // ListingDetails
    // A struct containing a Listing's data.
    //
    pub struct ListingDetails {
        // The Storefront that the Listing is stored in.
        // Note that this resource cannot be moved to a different Storefront,
        // so this is OK. If we ever make it so that it *can* be moved,
        // this should be revisited.
        pub var storefrontID: UInt64

        // Whether this listing has been purchased or not.
        pub var purchased: Bool

        // The ID of the NFT within that type.
        pub let nftID: UInt64

        // The amount that must be paid in the specified FungibleToken.
        pub let price: UFix64

        // setToPurchased
        // Irreversibly set this listing as purchased.
        //
        access(contract) fun setToPurchased() {
            self.purchased = true
        }

        // initializer
        //
        init (
            nftID: UInt64,
            price: UFix64,
            storefrontID: UInt64
        ) {
            self.storefrontID = storefrontID
            self.purchased = false
            self.nftID = nftID
            self.price = price
        }
    }

    // ListingMarketplace
    //
    pub resource interface ListingMarketplace {
        pub fun purchaseFromMarketplace(payment: @FungibleToken.Vault, marketplaceFee: UFix64): @NonFungibleToken.NFT
        pub fun borrowNFT(): &NonFungibleToken.NFT
        pub fun getDetails(): ListingDetails
    }

    // ListingPublic
    // An interface providing a useful public interface to a Listing.
    //
    pub resource interface ListingPublic {
        pub fun purchase(payment: @FungibleToken.Vault): @NonFungibleToken.NFT
        pub fun borrowNFT(): &NonFungibleToken.NFT
        pub fun getDetails(): ListingDetails
    }


    // Listing
    // A resource that allows an NFT to be sold for an amount of a given FungibleToken,
    // and for the proceeds of that sale to be split between several recipients.
    // 
    pub resource Listing: ListingPublic, ListingMarketplace {
        // The simple (non-Capability, non-complex) details of the sale
        access(self) let details: ListingDetails

        // the seller's nft provider allowing the nft to be withdrawn on purchase
        // todo: this should be revised when we implment albums
        access(contract) let nftProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.CollectionPublic, NonFungibleToken.Provider}>

        // the seller's receiver that will be deposited fusd on sale
        access(contract) let paymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
        
        init (
            nftProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.CollectionPublic, NonFungibleToken.Provider}>,
            nftID: UInt64,
            paymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>,
            price: UFix64,
            storefrontID: UInt64
        ) {
            // Store the sale information
            self.details = ListingDetails(
                nftID: nftID,
                price: price,
                storefrontID: storefrontID
            )

            // Store the NFT provider
            self.nftProvider = nftProvider

            // save the seller receiver
            self.paymentReceiver = paymentReceiver

            // Check that the provider contains the NFT.
            // We will check it again when the token is sold.
            // We cannot move this into a function because initializers cannot call member functions.
            let provider = self.nftProvider.borrow()
            assert(provider != nil, message: "cannot borrow nftProvider")

            // This will precondition assert if the token is not available.
            let nft = provider!.borrowSingle(id: self.details.nftID)!
            assert(nft.id == self.details.nftID, message: "token does not have specified ID")
        }

        // borrowNFT
        // This will assert in the same way as the NFT standard borrowNFT()
        // if the NFT is absent, for example if it has been sold via another listing.
        //
        pub fun borrowNFT(): &NonFungibleToken.NFT {
            let ref = self.nftProvider.borrow()!.borrowNFT(id: self.getDetails().nftID)
            assert(ref.id == self.getDetails().nftID, message: "token has wrong ID")
            return ref as &NonFungibleToken.NFT
        }

        // getDetails
        // Get the details of the current state of the Listing as a struct.
        // This avoids having more public variables and getter methods for them, and plays
        // nicely with scripts (which cannot return resources).
        //
        pub fun getDetails(): ListingDetails {
            return self.details
        }

        // Purchase the listing from a marketplace
        // This takes the Marketplace payout into account
        //
        pub fun purchaseFromMarketplace(payment: @FungibleToken.Vault, marketplaceFee: UFix64): @NonFungibleToken.NFT {
            pre {
                self.details.purchased == false: "listing has already been purchased"
                payment.balance == self.details.price - marketplaceFee: "payment vault does not contain requested price"
            }

            // Make sure the listing cannot be purchased again.
            self.details.setToPurchased()

            let single = self.nftProvider.borrow()!.borrowSingle(id: self.details.nftID)!

            // Neither receivers nor providers are trustworthy, they must implement the correct
            // interface but beyond complying with its pre/post conditions they are not gauranteed
            // to implement the functionality behind the interface in any given way.
            // Therefore we cannot trust the Collection resource behind the interface,
            // and we must check the NFT resource it gives us to make sure that it is the correct one.
            assert(single.id == self.details.nftID, message: "withdrawn NFT does not have specified ID")

            let payouts: [BlockRecords.Payout] = single.metadata["payouts"]! as! [BlockRecords.Payout]

            // distribute payouts
            for payout in payouts {
                if let receiver = payout.receiver.borrow() {
                   let p <- payment.withdraw(amount: payout.percentFee * self.details.price)
                    receiver.deposit(from: <-p)
                }
            }

            // pay the receiver
            self.paymentReceiver.borrow()!.deposit(from: <-payment)

            // If the listing is purchased, we regard it as completed here.
            // Otherwise we regard it as completed in the destructor.
            emit ListingCompleted(
                listingResourceID: self.uuid,
                storefrontResourceID: self.details.storefrontID,
                purchased: self.details.purchased
            )

            // Fetch the token to return to the purchaser.
            let nft <-self.nftProvider.borrow()!.withdraw(withdrawID: self.details.nftID)

            return <-nft
        }

        // purchase
        // Purchase the listing, buying the token.
        // This pays the beneficiaries and returns the token to the buyer.
        //
        pub fun purchase(payment: @FungibleToken.Vault): @NonFungibleToken.NFT {
            pre {
                self.details.purchased == false: "listing has already been purchased"
                payment.balance == self.details.price: "payment vault does not contain requested price"
            }

            // Make sure the listing cannot be purchased again.
            self.details.setToPurchased()

            let single = self.nftProvider.borrow()!.borrowSingle(id: self.details.nftID)!

            // Neither receivers nor providers are trustworthy, they must implement the correct
            // interface but beyond complying with its pre/post conditions they are not gauranteed
            // to implement the functionality behind the interface in any given way.
            // Therefore we cannot trust the Collection resource behind the interface,
            // and we must check the NFT resource it gives us to make sure that it is the correct one.
            assert(single.id == self.details.nftID, message: "withdrawn NFT does not have specified ID")

            let payouts: [BlockRecords.Payout] = single.metadata["payouts"]! as! [BlockRecords.Payout]

            // distribute payouts
            for payout in payouts {
                if let receiver = payout.receiver.borrow() {
                   let p <- payment.withdraw(amount: payout.percentFee * self.details.price)
                    receiver.deposit(from: <-p)
                }
            }

            // pay the receiver
            self.paymentReceiver.borrow()!.deposit(from: <-payment)

            // If the listing is purchased, we regard it as completed here.
            // Otherwise we regard it as completed in the destructor.
            emit ListingCompleted(
                listingResourceID: self.uuid,
                storefrontResourceID: self.details.storefrontID,
                purchased: self.details.purchased
            )

            // Fetch the token to return to the purchaser.
            let nft <-self.nftProvider.borrow()!.withdraw(withdrawID: self.details.nftID)

            return <-nft
        }

        // destructor
        //
        destroy () {
            // If the listing has not been purchased, we regard it as completed here.
            // Otherwise we regard it as completed in purchase().
            // This is because we destroy the listing in Storefront.removeListing()
            // or Storefront.cleanup() .
            // If we change this destructor, revisit those functions.
            if !self.details.purchased {
                emit ListingCompleted(
                    listingResourceID: self.uuid,
                    storefrontResourceID: self.details.storefrontID,
                    purchased: self.details.purchased
                )
            }
        }
    }

    init () {
        self.StorefrontStoragePath = /storage/BlockRecordsStorefront
        self.StorefrontPublicPath = /public/BlockRecordsStorefront
        self.StorefrontManagerPath = /private/BlockRecordsStorefrontManager
        self.StorefrontMarketplacePath = /private/BlockRecordsStorefrontMarketplace

        emit ContractInitialized()
    }
}
 
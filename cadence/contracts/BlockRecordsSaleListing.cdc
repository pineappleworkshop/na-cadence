
import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS

/* 

SaleListings allow BlockRecordsNFT owners to create a resource that effectively puts 
their NFTs up for sale. 

Buyers can purchase these NFTs for sale by providing a capability to an FUSD vault
with a sufficient balance. Payouts will be distributed to the BlockRecordsMarketplace 
facilitating the transaction and to the vault provided by the BlockRecordsRelease 
associated with the NFT. The leftover FUSD will be deposited into the vault provided 
by the seller and the NFT will be transferred into the collection provided by the buyer.

*/

pub contract BlockRecordsSaleListing {
    // SaleListing events.
    //
    // a sale offer has been created.
    pub event SaleListingCreated(
        id: UInt64, 
        price: UFix64,
    )

    // an item was purchased
    pub event SaleListingAccepted(
        id: UInt64, 
        price: UFix64,
        seller: Address? 
    )

    // a sale offer has been destroyed, with or without being accepted.
    pub event SaleListingFinished(id: UInt64)
    
    // a sale offer has been removed from the collection of Address.
    pub event CollectionRemovedSaleListing(
        id: UInt64, 
        seller: Address?
    )

    // a sale offer has been inserted into the collection of Address.
    pub event CollectionInsertedSaleListing(
        id: UInt64,
        price: UFix64, 
        seller: Address?,
    )

    pub event Event(type: String, metadata: {String: String})

    // Named paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    // An interface providing a read-only view of a SaleListing
    //
    pub resource interface SaleListingPublicView {
        pub let id: UInt64
        pub let price: UFix64
    }

    // the total number of SaleListings that have been created
    //
    pub var totalSupply: UInt64

    // a BlockRecordsNFT NFT being offered to sale for a set fee paid in FUSD.
    //
    pub resource SaleListing: SaleListingPublicView {
        // whether the sale has completed with someone purchasing the item.
        pub var saleCompleted: Bool

        // the SaleListing ID
        pub let id: UInt64

        // the BlockRecordsNFTID
        pub let nftID: UInt64

        // the sale payment price.
        pub let price: UFix64

        // // the royalty percentage
        // pub let royalty: UFix64?

        // the collection containing that ID.
        access(self) let sellerItemProvider: Capability<&BlockRecordsNFT.Collection{BlockRecordsNFT.BlockRecordsNFTCollectionPublic, NonFungibleToken.Provider}>

        // the seller FUSD vault
        access(self) let sellerPaymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>

        // the beneficiary's FUSD vault 
        access(self) var beneficiaryReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
        
        // called by a purchaser to accept the sale offer.
        // if they send the correct payment in FUSD, and if the item is still available,
        // the BlockRecordsNFT NFT will be placed in their BlockRecordsNFT.Collection .
        //
        pub fun accept(
            buyerCollection: &BlockRecordsNFT.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        ) {
            pre {
                buyerPayment.balance == self.price: "payment does not equal offer price"
                self.saleCompleted == false: "the sale offer has already been accepted"
            }

            self.saleCompleted = true

            let BlockRecordsNFT = self.sellerItemProvider.borrow()!.borrowBlockRecordsNFT(id: self.nftID)!

            let marketplace = getAccount(0xSERVICE_ACCOUNT_ADDRESS).getCapability<&BlockRecordsMarketplace.Marketplace{BlockRecordsMarketplace.MarketplacePublic}>(BlockRecordsMarketplace.MarketplacePublicPath).borrow()!

            // distribute release payouts
            let release = marketplace.borrowReleaseByNFTID(1)
            let releaseFee <- buyerPayment.withdraw(amount: self.price * release.payout.percentFee)
            release.payout.fusdVault.borrow()!.deposit(from: <- releaseFee)

            // distribute marketplace payouts
            let marketplaceFee <- buyerPayment.withdraw(amount: self.price * marketplace.payout.percentFee)
            marketplace.payout.fusdVault.borrow()!.deposit(from: <- marketplaceFee)

            // deposit the rest of the payment into Seller account vault
            self.sellerPaymentReceiver.borrow()!.deposit(from: <-buyerPayment)

            // Withdraw nft from Seller account collection and deposit into Buyer's
            let nft <- self.sellerItemProvider.borrow()!.withdraw(withdrawID: BlockRecordsNFT.id)
            buyerCollection.deposit(token: <-nft)

            emit SaleListingAccepted(id: self.id, price: self.price, seller: self.owner?.address)

            emit Event(type: "sale_listing_completed", metadata: {
                "id": self.id.toString()
            })
        }

        destroy() {
        // whether the sale completed or not, publicize that it is being withdrawn.
            emit SaleListingFinished(id: self.id)
        }

        init(
            id: UInt64,
            nftID: UInt64,
            sellerItemProvider: Capability<&BlockRecordsNFT.Collection{BlockRecordsNFT.BlockRecordsNFTCollectionPublic, NonFungibleToken.Provider}>,
            sellerPaymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>,
            price: UFix64
        ) {
            pre {
                sellerItemProvider.borrow() != nil: "Cannot borrow seller"
                sellerPaymentReceiver.borrow() != nil: "Cannot borrow sellerPaymentReceiver"
            }

            self.saleCompleted = false

            self.id = id
            self.nftID = nftID
            self.sellerItemProvider = sellerItemProvider
            self.sellerPaymentReceiver = sellerPaymentReceiver
            self.price = price

            self.beneficiaryReceiver = getAccount(0xSERVICE_ACCOUNT_ADDRESS).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!

            emit SaleListingCreated(id: self.id, price: self.price)

            emit Event(type: "sale_listing_for_sale", metadata: {
                "id" : self.id.toString(),
                "nft_id" : self.nftID.toString(),
                "price": self.price.toString()
            })

            BlockRecordsSaleListing.totalSupply = BlockRecordsSaleListing.totalSupply + (1 as UInt64)
        }
    }

    // createSaleListing
    // make creating a SaleListing publicly accessible.
    //
    pub fun createSaleListing (
        nftID: UInt64,
        sellerItemProvider: Capability<&BlockRecordsNFT.Collection{BlockRecordsNFT.BlockRecordsNFTCollectionPublic, NonFungibleToken.Provider}>,
        sellerPaymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>,
        price: UFix64,
    ): @SaleListing {
        let id = BlockRecordsSaleListing.totalSupply
        
        return <-create SaleListing(
            id: id,
            nftID: nftID,
            sellerItemProvider: sellerItemProvider,
            sellerPaymentReceiver: sellerPaymentReceiver,
            price: price
        )
    }

    // CollectionManager
    // An interface for adding and removing SaleListings to a collection, intended for
    // use by the collection's owner.
    //
    pub resource interface CollectionManager {
        pub fun insert(offer: @BlockRecordsSaleListing.SaleListing)
        pub fun remove(id: UInt64): @SaleListing 
    }

    // CollectionPurchaser
    // An interface to allow purchasing items via SaleListings in a collection.
    // This function is also provided by CollectionPublic, it is here to support
    // more fine-grained access to the collection for as yet unspecified future use cases.
    //
    pub resource interface CollectionPurchaser {
        pub fun purchase(
            id: UInt64,
            buyerCollection: &BlockRecordsNFT.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        )
    }

    // CollectionPublic
    // An interface to allow listing and borrowing SaleListings, and purchasing items via SaleListings in a collection.
    //
    pub resource interface CollectionPublic {
        pub fun getSaleListingIDs(): [UInt64]
        pub fun borrowSaleListing(id: UInt64): &SaleListing{SaleListingPublicView}?
        pub fun purchase(
            id: UInt64,
            buyerCollection: &BlockRecordsNFT.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        )
    }

    // Collection
    // a resource that allows its owner to manage a list of SaleListings, and purchasers to interact with them.
    //
    pub resource Collection : CollectionManager, CollectionPurchaser, CollectionPublic {
        pub var saleOffers: @{UInt64: SaleListing}

        // insert
        // Insert a SaleListing into the collection, replacing one with the same id if present.
        //
        pub fun insert(offer: @BlockRecordsSaleListing.SaleListing) {
        let id: UInt64 = offer.id
        let price: UFix64 = offer.price

        // add the new offer to the dictionary which removes the old one
        let oldOffer <- self.saleOffers[id] <- offer
        destroy oldOffer

        emit CollectionInsertedSaleListing(
            id: id,
            price: price,
            seller: self.owner?.address
        )
        }

        // remove and return a SaleListing from the collection.
        pub fun remove(id: UInt64): @SaleListing {
            emit CollectionRemovedSaleListing(id: id, seller: self.owner?.address)

            emit Event(type: "sale_listing_cancelled", metadata: {
                "id" : id.toString()
            })

            return <-(self.saleOffers.remove(key: id) 
                ?? panic("missing SaleListing"))
        }

        pub fun purchase(
            id: UInt64,
            buyerCollection: &BlockRecordsNFT.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        ) {
            pre {
                self.saleOffers[id] != nil: "SaleListing does not exist in the collection!"
            }

            let offer <-(self.saleOffers.remove(key: id) 
                ?? panic("missing SaleListing"))
            offer.accept(buyerCollection: buyerCollection, buyerPayment: <-buyerPayment)
            destroy offer
        }

        // returns an array of the IDs that are in the collection
        //
        pub fun getSaleListingIDs(): [UInt64] {
            return self.saleOffers.keys
        }

        // returns an Optional read-only view of the SaleListing for the given id if it is contained by this collection.
        // the optional will be nil if the provided id is not present in the collection.
        //
        pub fun borrowSaleListing(id: UInt64): &SaleListing{SaleListingPublicView}? {
            if self.saleOffers[id] == nil {
                return nil
            } else {
                return &self.saleOffers[id] as &SaleListing{SaleListingPublicView}
            }
        }

        destroy () {
        destroy self.saleOffers
        }

        init () {
            self.saleOffers <- {}
        }
    }

    // make creating a Collection publicly accessible.
    //
    pub fun createEmptyCollection(): @Collection {
        return <-create Collection()
    }

    init () {
        self.CollectionStoragePath = /storage/BlockRecordsSaleListingCollection
        self.CollectionPublicPath = /public/BlockRecordsSaleListingCollection
        self.totalSupply = 0
    }
}

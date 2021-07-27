// import FUSD from "./FUSD.cdc"
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

/*
    This is a simple BlockRecordsSingle initial sale contract for the DApp to use
    in order to list and sell BlockRecordsSingle.

    Its structure is neither what it would be if it was the simplest possible
    market contract or if it was a complete general purpose market contract.
    Rather it's the simplest possible version of a more general purpose
    market contract that indicates how that contract might function in
    broad strokes. This has been done so that integrating with this contract
    is a useful preparatory exercise for code that will integrate with the
    later more general purpose market contract.

    It allows:
    - Anyone to create Sale Offers and place them in a collection, making it
      publicly accessible.
    - Anyone to accept the offer and buy the item.

    It notably does not handle:
    - Multiple different sale NFT contracts.
    - Multiple different payment FT contracts.
    - Splitting sale payments to multiple recipients.

 */

pub contract BlockRecordsMarket {
    // SaleListing events.
    //
    // A sale offer has been created.
    pub event SaleListingCreated(
        id: UInt64, 
        price: UFix64,
    )

    // Someone has purchased an item that was offered for sale.
    pub event SaleListingAccepted(
        id: UInt64, 
        price: UFix64,
        seller: Address? 
    )

    // A sale offer has been destroyed, with or without being accepted.
    pub event SaleListingFinished(id: UInt64)
    
    // Collection events.
    //
    // A sale offer has been removed from the collection of Address.
    pub event CollectionRemovedSaleListing(
        id: UInt64, 
        seller: Address?
    )

    // A sale offer has been inserted into the collection of Address.
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

    // SaleListingPublicView
    // An interface providing a read-only view of a SaleListing
    //
    pub resource interface SaleListingPublicView {
        pub let id: UInt64
        pub let price: UFix64
    }

    // totalSupply
    // The total number of SaleListings that have been created
    //
    pub var totalSupply: UInt64

    // SaleListing
    // A BlockRecordsSingle NFT being offered to sale for a set fee paid in FUSD.
    //
    pub resource SaleListing: SaleListingPublicView {
        // Whether the sale has completed with someone purchasing the item.
        pub var saleCompleted: Bool

        // The SaleListing ID
        pub let id: UInt64

        // The BlockRecordsSingleID
        pub let nftID: UInt64

        // The sale payment price.
        pub let price: UFix64

        // // The royalty percentage
        // pub let royalty: UFix64?

        // The beneficiary fee percentage
        pub var fee: UFix64

        // The collection containing that ID.
        access(self) let sellerItemProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.BlockRecordsSingleCollectionPublic, NonFungibleToken.Provider}>

        // The seller FUSD vault
        access(self) let sellerPaymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>

        // The beneficiary's FUSD vault 
        access(self) var beneficiaryReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>

        // The royalty receiver's FUSD vault
        // access(self) let royaltyReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>?

        // Called by a purchaser to accept the sale offer.
        // If they send the correct payment in FUSD, and if the item is still available,
        // the BlockRecordsSingle NFT will be placed in their BlockRecordsSingle.Collection .
        //
        pub fun accept(
            buyerCollection: &BlockRecordsSingle.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        ) {
            pre {
                buyerPayment.balance == self.price: "payment does not equal offer price"
                self.saleCompleted == false: "the sale offer has already been accepted"
            }

            self.saleCompleted = true

            let blockRecordsSingle = self.sellerItemProvider.borrow()!.borrowBlockRecordsSingle(id: self.nftID)!

            let royaltyAddress: Address = blockRecordsSingle.metadata["royalty_address"]! as! Address
            let royaltyPercentage: UInt64 = blockRecordsSingle.metadata["royalty_percentage"]! as! UInt64
            let royalty: UFix64 = UFix64(UFix64(royaltyPercentage!) / UFix64(100))

            // Distribute royalties
            let royaltyAmnt = self.price * royalty
            let royaltyFee <- buyerPayment.withdraw(amount: royaltyAmnt)
            let royaltyAccount = getAccount(royaltyAddress!)
            let royaltyReceiver = royaltyAccount.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)! 
            royaltyReceiver.borrow()!.deposit(from: <-royaltyFee)

            // Pay BlockRecords fee
            let beneficiaryAmnt = self.price * self.fee
            let beneficiaryFee <- buyerPayment.withdraw(amount: beneficiaryAmnt)
            self.beneficiaryReceiver.borrow()!.deposit(from: <-beneficiaryFee)

            // Deposit the rest of the payment into Seller account vault
            self.sellerPaymentReceiver.borrow()!.deposit(from: <-buyerPayment)

            // Withdraw nft from Seller account collection and deposit into Buyer's
            let nft <- self.sellerItemProvider.borrow()!.withdraw(withdrawID: blockRecordsSingle.id)
            buyerCollection.deposit(token: <-nft)

            emit SaleListingAccepted(id: self.id, price: self.price, seller: self.owner?.address)

            emit Event(type: "sale_listing_completed", metadata: {
                "id": self.id.toString()
            })
        }

        // destructor
        //
        destroy() {
            // Whether the sale completed or not, publicize that it is being withdrawn.
            emit SaleListingFinished(id: self.id)
        }

        // initializer
        // Take the information required to create a sale offer, notably the capability
        // to transfer the BlockRecordsSingle NFT and the capability to receive FUSD in payment.
        //
        // TODO: we might want to hardcode the fee into the smart contract
        // minters could potentially set the fee to whatever they want with this current implementation
        init(
            id: UInt64,
            nftID: UInt64,
            sellerItemProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.BlockRecordsSingleCollectionPublic, NonFungibleToken.Provider}>,
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

            // todo: should fee and beneficiary receiver go here?
            // conceptually, it makes sense that the fee and receiver
            // would be explicitly defined in the smart contract itself
            self.fee = 0.05
            self.beneficiaryReceiver = getAccount(0xSERVICE_ACCOUNT_ADDRESS).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!

            emit SaleListingCreated(id: self.id, price: self.price)

            emit Event(type: "sale_listing_for_sale", metadata: {
                "id" : self.id.toString(),
                "nft_id" : self.nftID.toString(),
                "price": self.price.toString()
            })

            BlockRecordsMarket.totalSupply = BlockRecordsMarket.totalSupply + (1 as UInt64)
        }
    }

    // createSaleListing
    // Make creating a SaleListing publicly accessible.
    //
    pub fun createSaleListing (
        nftID: UInt64,
        sellerItemProvider: Capability<&BlockRecordsSingle.Collection{BlockRecordsSingle.BlockRecordsSingleCollectionPublic, NonFungibleToken.Provider}>,
        sellerPaymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>,
        price: UFix64,
    ): @SaleListing {
        let id = BlockRecordsMarket.totalSupply
        
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
        pub fun insert(offer: @BlockRecordsMarket.SaleListing)
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
            buyerCollection: &BlockRecordsSingle.Collection{NonFungibleToken.Receiver},
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
            buyerCollection: &BlockRecordsSingle.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        )
   }

    // Collection
    // A resource that allows its owner to manage a list of SaleListings, and purchasers to interact with them.
    //
    pub resource Collection : CollectionManager, CollectionPurchaser, CollectionPublic {
        pub var saleOffers: @{UInt64: SaleListing}

        // insert
        // Insert a SaleListing into the collection, replacing one with the same id if present.
        //
         pub fun insert(offer: @BlockRecordsMarket.SaleListing) {
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

        // remove
        // Remove and return a SaleListing from the collection.
        pub fun remove(id: UInt64): @SaleListing {
            emit CollectionRemovedSaleListing(id: id, seller: self.owner?.address)

            emit Event(type: "sale_listing_cancelled", metadata: {
                "id" : id.toString()
            })

            return <-(self.saleOffers.remove(key: id) ?? panic("missing SaleListing"))
        }
 
        // purchase
        // If the caller passes a valid id and the item is still for sale, and passes a FUSD vault
        // typed as a FungibleToken.Vault (FUSD.deposit() handles the type safety of this)
        // containing the correct payment amount, this will transfer the KittyItem to the caller's
        // BlockRecordsSingle collection.
        // It will then remove and destroy the offer.
        // Note that is means that events will be emitted in this order:
        //   1. Collection.CollectionRemovedSaleListing
        //   2. BlockRecordsSingle.Withdraw
        //   3. BlockRecordsSingle.Deposit
        //   4. SaleListing.SaleListingFinished
        //
        pub fun purchase(
            id: UInt64,
            buyerCollection: &BlockRecordsSingle.Collection{NonFungibleToken.Receiver},
            buyerPayment: @FungibleToken.Vault
        ) {
            pre {
                self.saleOffers[id] != nil: "SaleListing does not exist in the collection!"
            }
            let offer <-(self.saleOffers.remove(key: id) ?? panic("missing SaleListing"))
            offer.accept(buyerCollection: buyerCollection, buyerPayment: <-buyerPayment)
            //FIXME: Is this correct? Or should we return it to the caller to dispose of?
            destroy offer
        }

        // getSaleListingIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getSaleListingIDs(): [UInt64] {
            return self.saleOffers.keys
        }

        // borrowSaleListing
        // Returns an Optional read-only view of the SaleListing for the given id if it is contained by this collection.
        // The optional will be nil if the provided id is not present in the collection.
        //
        pub fun borrowSaleListing(id: UInt64): &SaleListing{SaleListingPublicView}? {
            if self.saleOffers[id] == nil {
                return nil
            } else {
                return &self.saleOffers[id] as &SaleListing{SaleListingPublicView}
            }
        }

        // destructor
        //
        destroy () {
            destroy self.saleOffers
        }

        // constructor
        //
        init () {
            self.saleOffers <- {}
        }
    }

    // createEmptyCollection
    // Make creating a Collection publicly accessible.
    //
    pub fun createEmptyCollection(): @Collection {
        return <-create Collection()
    }

    init () {
        //FIXME: REMOVE SUFFIX BEFORE RELEASE
        self.CollectionStoragePath = /storage/BlockRecordsMarketCollection002
        self.CollectionPublicPath = /public/BlockRecordsMarketCollection002

        // Initialize the total supply
        self.totalSupply = 0
    }
}

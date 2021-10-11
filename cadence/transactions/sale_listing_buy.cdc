import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsStorefront from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(
    listingID: UInt64, 
    storefrontAddress: Address
) {
    let payment: @FungibleToken.Vault
    let singleCollection: &BlockRecordsSingle.Collection{NonFungibleToken.Receiver}
    let storefront: &BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}

    prepare(signer: AuthAccount) {
        self.storefront = getAccount(storefrontAddress).getCapability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>(BlockRecordsStorefront.StorefrontPublicPath)!.borrow()
            ?? panic("Could not borrow market collection from market address")

        // get listing price
        let listing = self.storefront.borrowListing(listingResourceID: listingID)
            ?? panic("No listing with that ID")
        let listingDetail = listing.getDetails()
        let price = listingDetail.price

        // create payment
        let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.payment <- fusdVault.withdraw(amount: price)

        self.singleCollection = signer.borrow<&BlockRecordsSingle.Collection{NonFungibleToken.Receiver}>(from: BlockRecordsSingle.CollectionStoragePath) 
            ?? panic("Cannot borrow BlockRecordsSingle collection receiver from acct")
    }

    execute {
        let nft <- self.storefront.purchaseListing(listingResourceID: listingID, payment: <- self.payment)
        destroy nft
    }
}
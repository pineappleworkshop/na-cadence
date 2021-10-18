import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsStorefront from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(
    listingID: UInt64, 
    storefrontAddress: Address
) {
    let payment: @FungibleToken.Vault
    let marketplace: &BlockRecordsMarketplace.Marketplace{BlockRecordsMarketplace.MarketplacePublic}

    prepare(signer: AuthAccount) {
        // get marketplace public from service account
        self.marketplace = getAccount(0xSERVICE_ACCOUNT_ADDRESS).getCapability<&BlockRecordsMarketplace.Marketplace{BlockRecordsMarketplace.MarketplacePublic}>(BlockRecordsMarketplace.MarketplacePublicPath)!.borrow()
            ?? panic("could not borrow marketplace from service account")

        // get listing from storefront
        let listing = self.marketplace.borrowListingFromStorefront(
            listingID: listingID, 
            storefrontAddress: storefrontAddress
        )!
        let listingDetails = listing.getDetails()
        let price = listingDetails.price

        // create payment
        let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.payment <- fusdVault.withdraw(amount: price)
    }

    execute {
        let nft <- self.marketplace.purchaseListingFromStorefront(
            listingID: listingID,
            storefrontAddress: storefrontAddress,
            payment: <- self.payment
        )
        destroy nft
    }
}
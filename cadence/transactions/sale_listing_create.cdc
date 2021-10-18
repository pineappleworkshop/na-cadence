import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsStorefront from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(
    nftID: UInt64, 
    price: UFix64
) {
    let nftProvider: Capability<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>
    let paymentReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let storefrontManager: &BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontManager}

    prepare(signer: AuthAccount) {        
        self.paymentReceiver = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        
        // initialize provider if needed
        if !signer.getCapability<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>(BlockRecordsSingle.CollectionProviderPath)!.check() {
            signer.link<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>(
                BlockRecordsSingle.CollectionProviderPath, 
                target: BlockRecordsSingle.CollectionStoragePath
            )
        }

        self.nftProvider = signer.getCapability<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>(BlockRecordsSingle.CollectionProviderPath)!

        self.storefrontManager = signer.getCapability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontManager}>(BlockRecordsStorefront.StorefrontManagerPath).borrow()
            ?? panic("missing or invalid provider")
    }

    execute {
        let offerID = self.storefrontManager.createListing (
            nftProvider: self.nftProvider,
            nftID: nftID,
            paymentReceiver: self.paymentReceiver,
            price: price,
        )
    }
}
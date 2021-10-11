import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSaleListing from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(id: UInt64, price: UFix64) {
    let sellerFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let BlockRecordsSingleCollection: Capability<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>
    let marketCollection: &BlockRecordsSaleListing.Collection

    prepare(signer: AuthAccount) {
        let BlockRecordsCollectionProviderPrivatePath = /private/BlockRecordsCollectionProvider
        
        self.sellerFUSDVault = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        
        assert(self.sellerFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver")
        
        if !signer.getCapability<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>(BlockRecordsCollectionProviderPrivatePath)!.check() {
            signer.link<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>(BlockRecordsCollectionProviderPrivatePath, target: BlockRecordsSingle.CollectionStoragePath)
        }

        self.BlockRecordsSingleCollection = signer.getCapability<&BlockRecordsSingle.Collection{NonFungibleToken.Provider, BlockRecordsSingle.CollectionPublic}>(BlockRecordsCollectionProviderPrivatePath)!

        assert(self.BlockRecordsSingleCollection.borrow() != nil, message: "Missing or mis-typed BlockRecordsSingleCollection provider")
        
        self.marketCollection = signer.borrow<&BlockRecordsSaleListing.Collection>(from: BlockRecordsSaleListing.CollectionStoragePath)
            ?? panic("Missing or mis-typed BlockRecordsSaleListing Collection")
        // let saleListing = self.marketCollection.borrowSaleListing(id: id)
        //     ?? panic("No item with ID")
    }

    execute {
        let offer <- BlockRecordsSaleListing.createSaleListing (
            nftID: id,
            sellerItemProvider: self.BlockRecordsSingleCollection,
            sellerPaymentReceiver: self.sellerFUSDVault,
            price: price
        )
        self.marketCollection.insert(offer: <-offer)
    }
}
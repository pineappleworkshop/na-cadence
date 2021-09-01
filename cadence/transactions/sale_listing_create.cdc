import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSaleListing from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(id: UInt64, price: UFix64) {
    let sellerFUSDVault: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let BlockRecordsNFTCollection: Capability<&BlockRecordsNFT.Collection{NonFungibleToken.Provider, BlockRecordsNFT.CollectionPublic}>
    let marketCollection: &BlockRecordsSaleListing.Collection

    prepare(signer: AuthAccount) {
        let BlockRecordsCollectionProviderPrivatePath = /private/BlockRecordsCollectionProvider
        
        self.sellerFUSDVault = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        
        assert(self.sellerFUSDVault.borrow() != nil, message: "Missing or mis-typed FUSD receiver")
        
        if !signer.getCapability<&BlockRecordsNFT.Collection{NonFungibleToken.Provider, BlockRecordsNFT.CollectionPublic}>(BlockRecordsCollectionProviderPrivatePath)!.check() {
            signer.link<&BlockRecordsNFT.Collection{NonFungibleToken.Provider, BlockRecordsNFT.CollectionPublic}>(BlockRecordsCollectionProviderPrivatePath, target: BlockRecordsNFT.CollectionStoragePath)
        }

        self.BlockRecordsNFTCollection = signer.getCapability<&BlockRecordsNFT.Collection{NonFungibleToken.Provider, BlockRecordsNFT.CollectionPublic}>(BlockRecordsCollectionProviderPrivatePath)!

        assert(self.BlockRecordsNFTCollection.borrow() != nil, message: "Missing or mis-typed BlockRecordsNFTCollection provider")
        
        self.marketCollection = signer.borrow<&BlockRecordsSaleListing.Collection>(from: BlockRecordsSaleListing.CollectionStoragePath)
            ?? panic("Missing or mis-typed BlockRecordsSaleListing Collection")
        // let saleListing = self.marketCollection.borrowSaleListing(id: id)
        //     ?? panic("No item with ID")
    }

    execute {
        let offer <- BlockRecordsSaleListing.createSaleListing (
            nftID: id,
            sellerItemProvider: self.BlockRecordsNFTCollection,
            sellerPaymentReceiver: self.sellerFUSDVault,
            price: price
        )
        self.marketCollection.insert(offer: <-offer)
    }
}
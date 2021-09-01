import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsSaleListing from 0xSERVICE_ACCOUNT_ADDRESS

transaction {

    prepare(acct: AuthAccount) {
    
        // BlockRecordsNFT Collection
        // account resource collection for nfts
        //
        if acct.borrow<&BlockRecordsNFT.Collection>(from: /storage/BlockRecordsNFTCollection) != nil {
            return
        }

        let collection <- BlockRecordsNFT.createEmptyCollection()
        acct.save(<-collection, to: /storage/BlockRecordsNFTCollection)
        
        acct.unlink(/public/BlockRecordsNFTCollection)
        acct.link<&{NonFungibleToken.CollectionPublic, BlockRecordsNFT.CollectionPublic}>(
            /public/BlockRecordsNFTCollection,
            target: /storage/BlockRecordsNFTCollection
        )    
            
        // FUSD
        // account resource collection for FUSD tokens
        //
        let existingVault = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
        if (existingVault != nil) {
            return
        }
        acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)

        acct.link<&FUSD.Vault{FungibleToken.Receiver}>(
            /public/fusdReceiver,
            target: /storage/fusdVault
        )

        acct.link<&FUSD.Vault{FungibleToken.Balance}>(
            /public/fusdBalance,
            target: /storage/fusdVault
        )
        
        // BlockRecordsSaleListing Collection
        // account resource collection for nft sale listings
        //
        if acct.borrow<&BlockRecordsSaleListing.Collection>(from: BlockRecordsSaleListing.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- BlockRecordsSaleListing.createEmptyCollection() as! @BlockRecordsSaleListing.Collection
            acct.save(<-collection, to: BlockRecordsSaleListing.CollectionStoragePath)

            acct.link<&BlockRecordsSaleListing.Collection{BlockRecordsSaleListing.CollectionPublic}>(BlockRecordsSaleListing.CollectionPublicPath, target: BlockRecordsSaleListing.CollectionStoragePath)
        }
    }
}
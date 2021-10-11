import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsSaleListing from 0xSERVICE_ACCOUNT_ADDRESS

transaction {

    prepare(acct: AuthAccount) {
    
        // BlockRecordsSingle Collection
        // account resource collection for nfts
        //
        if acct.borrow<&BlockRecordsSingle.Collection>(from: /storage/BlockRecordsSingleCollection) != nil {
            return
        }

        let collection <- BlockRecordsSingle.createEmptyCollection()
        acct.save(<-collection, to: /storage/BlockRecordsSingleCollection)
        
        acct.unlink(/public/BlockRecordsSingleCollection)
        acct.link<&{NonFungibleToken.CollectionPublic, BlockRecordsSingle.CollectionPublic}>(
            /public/BlockRecordsSingleCollection,
            target: /storage/BlockRecordsSingleCollection
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
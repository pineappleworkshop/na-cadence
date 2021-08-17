  import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
  import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
  import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
  import FUSD from 0xFUSD_CONTRACT_ADDRESS
  import BlockRecordsMarket from 0xSERVICE_ACCOUNT_ADDRESS
  
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
        acct.link<&{NonFungibleToken.CollectionPublic, BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>(
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
        
        // BlockRecordsMarket Collection
        // account resource collection for nft sale listings
        //
        if acct.borrow<&BlockRecordsMarket.Collection>(from: BlockRecordsMarket.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- BlockRecordsMarket.createEmptyCollection() as! @BlockRecordsMarket.Collection
            acct.save(<-collection, to: BlockRecordsMarket.CollectionStoragePath)

            acct.link<&BlockRecordsMarket.Collection{BlockRecordsMarket.CollectionPublic}>(BlockRecordsMarket.CollectionPublicPath, target: BlockRecordsMarket.CollectionStoragePath)
        }
      }
  }
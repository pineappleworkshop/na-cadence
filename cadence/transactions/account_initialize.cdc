  import NonFungibleToken from NFT_CONTRACT_ADDRESS
  import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS
  import FungibleToken from FUNGIBLE_TOKEN_CONTRACT_ADDRESS
  import FUSD from FUSD_CONTRACT_ADDRESS
  import BlockRecordsMarket from SERVICE_ACCOUNT_ADDRESS
  
  transaction {
  
      prepare(acct: AuthAccount) {
        
        // BlockRecordsSingle Collection
        // account resource collection for nfts
        //
        if acct.borrow<&BlockRecordsSingle.Collection>(from: /storage/BlockRecordsSingleCollection002) != nil {
            return
        }

        let collection <- BlockRecordsSingle.createEmptyCollection()
        acct.save(<-collection, to: /storage/BlockRecordsSingleCollection002)
        
        acct.unlink(/public/BlockRecordsSingleCollection002)
        acct.link<&{NonFungibleToken.CollectionPublic, BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>(
            /public/BlockRecordsSingleCollection002,
            target: /storage/BlockRecordsSingleCollection002
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
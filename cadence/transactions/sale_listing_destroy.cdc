  import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
  import BlockRecordsMarket from 0xSERVICE_ACCOUNT_ADDRESS
  
  transaction(id: UInt64) {
      prepare(account: AuthAccount) {
          let listing <- account
            .borrow<&BlockRecordsMarket.Collection>(from: BlockRecordsMarket.CollectionStoragePath)!
            .remove(id: id)
          destroy listing
      }
  }
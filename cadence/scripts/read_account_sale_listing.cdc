import BlockRecordsMarket from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

pub struct SaleListing {
  pub let price: UFix64
  pub let id: UInt64
  pub let metadata: {String: String}

  init(initPrice: UFix64, initID: UInt64, initMetadata: {String: String}) {
    self.price = initPrice
    self.id = initID
    self.metadata = initMetadata
  }
}

pub fun main(): SaleListing? {
  
  let id = (SINGLE_ID as UInt64)

  let seller = getAccount(0xACCOUNT_ADDRESS)

  let marketCollection = seller.getCapability(BlockRecordsMarket.CollectionPublicPath)!.borrow<&BlockRecordsMarket.Collection{BlockRecordsMarket.CollectionPublic}>()
        ?? panic("Could not borrow BlockRecordsMarket.CollectionPublic")

  let saleListingsData = marketCollection.borrowSaleListing(id: id) ?? panic("No such id in that collection")

  let blockRecordsCollection = seller.getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
      ?? panic("Could not borrow BlockRecordsSingleCollectionPublic")

  let blockRecordsSingleData = blockRecordsCollection.borrowBlockRecordsSingle(id: id)
      ?? panic("No such id in that collection")

  return SaleListing(initPrice: saleListingsData.price, initID: id, initMetadata: blockRecordsSingleData.metadata)
}
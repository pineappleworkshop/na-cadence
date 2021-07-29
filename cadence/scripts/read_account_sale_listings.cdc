import BlockRecordsMarket from SERVICE_ACCOUNT_ADDRESS
import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS

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

pub fun main(): [SaleListing?] {
  
  let seller = getAccount(0xACCOUNT_ADDRESS)

  let marketCollection = seller.getCapability(BlockRecordsMarket.CollectionPublicPath)!.borrow<&BlockRecordsMarket.Collection{BlockRecordsMarket.CollectionPublic}>()
        ?? panic("Could not borrow BlockRecordsMarket.CollectionPublic")

  let saleListingIDs  = marketCollection.getSaleListingIDs()

  let blockRecordsCollection = seller.getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
      ?? panic("Could not borrow BlockRecordsSingleCollectionPublic")

  let saleListings: [SaleListing?] = []
  var i = 0
  while i < saleListingIDs.length {
    let id = saleListingIDs[i]
    let saleListingData = marketCollection.borrowSaleListing(id: id) ?? panic("No such id in that market collection")
    let blockRecordsSingleData = blockRecordsCollection.borrowBlockRecordsSingle(id: id)
      ?? panic("No such id in block record collection")
    let saleListing = SaleListing(initPrice: saleListingData.price, initID: id, initMetadata: blockRecordsSingleData.metadata)
    saleListings.append(saleListing)
    i = i + 1
  }

  return saleListings
}
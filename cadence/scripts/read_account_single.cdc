import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

pub struct Single {
  pub let id: UInt64
  pub let metadata: {String: String}
  // todo: pub let encryptionKey: String
  
  init(initID: UInt64, initMetadata: {String: String}) {
    self.id = initID
    self.metadata = initMetadata
  }
}

pub fun main(id: UInt64): Single? {
  let owner = getAccount(0xACCOUNT_ADDRESS)

  let blockRecordsCollection = owner.getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
      ?? panic("Could not borrow BlockRecordsSingleCollectionPublic")

  // borrow a reference to a specific BlockRecordsSingle in the collection
  let blockRecordsSingleData = blockRecordsCollection.borrowBlockRecordsSingle(id: id)
      ?? panic("No such id in that collection")

  let single = Single(initID: blockRecordsSingleData.id, initMetadata: blockRecordsSingleData.metadata)

  return single
}
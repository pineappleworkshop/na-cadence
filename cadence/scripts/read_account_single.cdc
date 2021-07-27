import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

pub struct Single {
  pub let id: UInt64
  pub let metadata: {String: String}
  
  pub let encryptionKey: String
  
  init(initID: UInt64, initMetadata: {String: String}) {
    self.id = initID
    self.metadata = initMetadata
  }
}

pub fun main(id: UInt64): Single? {

    // get the public account object for the token owner
    let owner = getAccount(0xACCOUNT_ADDRESS)

    let blockRecordsCollection = owner.getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>()
        ?? panic("Could not borrow BlockRecordsSingleCollectionPublic")

    // borrow a reference to a specific BlockRecordsSingle in the collection
    let blockRecordsSingleData = blockRecordsCollection.borrowBlockRecordsSingle(id: id)
        ?? panic("No such id in that collection")

    let single = Single(initID: blockRecordsSingleData.id, initMetadata: blockRecordsSingleData.metadata)

    return single
}
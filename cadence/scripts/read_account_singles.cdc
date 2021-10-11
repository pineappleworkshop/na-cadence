import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

pub struct Single {
    pub let id: UInt64
    pub let metadata: {String: AnyStruct}

    init(initID: UInt64, initMetadata: {String: AnyStruct}) {
        self.id = initID
        self.metadata = initMetadata
    }
}

pub fun main(): [Single?]{
    let owner = getAccount(ACCOUNT_ADDRESS)

    let blockRecordsCollection = owner.getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&{BlockRecordsSingle.CollectionPublic}>()
        ?? panic("Could not borrow BlockRecordsSingle.CollectionPublic")

    let ids = blockRecordsCollection.getIDs()

    let singles: [Single?] = []
    var i = 0
    while i < ids.length {
        let id = ids[i]
        let blockRecordsSingleData = blockRecordsCollection.borrowSingle(id: id)
            ?? panic("No such id in that collection")
        let single = Single(initID: blockRecordsSingleData.id, initMetadata: blockRecordsSingleData.metadata)
        singles.append(single)
        i = i + 1
    }
    return singles
}
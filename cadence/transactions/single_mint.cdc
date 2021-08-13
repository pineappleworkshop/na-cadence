import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS

transaction(
    name: String, 
    type: String, 
    literation: String, 
    imageURL: String, 
    audioURL: String,
    copiesCount: Int,
    releaseID: UInt64
) {    
    let creator: &BlockRecordsSingle.Creator
    let receiverCollection: &{NonFungibleToken.CollectionPublic}
    
    prepare(signer: AuthAccount) {
        self.creator = signer.borrow<&BlockRecordsSingle.Creator>(from: BlockRecordsSingle.CreatorStoragePath)!
        self.receiverCollection = signer.getCapability(BlockRecordsSingle.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
    }

    execute {
        self.creator.mintSingle(
            name: name, 
            type: type, 
            literation: literation, 
            imageURL: imageURL, 
            audioURL: audioURL,
            copiesCount: copiesCount,
            releaseID: releaseID,
            receiverCollection: self.receiverCollection
        )
    }
}



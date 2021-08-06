import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS

transaction(
    name: String, 
    royaltyAddress: Address, 
    royaltyPercentage: UInt64, 
    type: String, 
    literation: String, 
    imageURL: String, 
    audioURL: String,
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
            royaltyAddress: royaltyAddress, 
            royaltyPercentage: royaltyPercentage, 
            type: type, 
            literation: literation, 
            imageURL: imageURL, 
            audioURL: audioURL,
            releaseID: releaseID,
            receiverCollection: self.receiverCollection
        )
    }
}



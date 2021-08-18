import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS

transaction(
    name: String, 
    type: String, 
    literation: String, 
    imageURL: String, 
    audioURL: String,
    copiesCount: Int,
    releaseID: UInt64
){    
    let creator: &BlockRecordsRelease.Creator
    let receiverCollection: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.creator = signer.borrow<&BlockRecordsRelease.Creator>(from: BlockRecordsRelease.CreatorStoragePath)!
        self.receiverCollection = signer.getCapability(BlockRecordsNFT.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()
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



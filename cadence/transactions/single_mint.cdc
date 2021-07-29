import NonFungibleToken from NFT_CONTRACT_ADDRESS
import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS

transaction(name: String, receiverAccountAddress: Address, royaltyAddress: Address, royaltyPercentage: UInt64, type: String, literation: String, imageUrl: String, audioUrl: String) {
    let minter: &BlockRecordsSingle.Creator
    prepare(signer: AuthAccount) {
        self.minter = signer.borrow<&BlockRecordsSingle.Creator>(from: /storage/BlockRecordsCreator002)!
    }
    execute {
        let recipient = getAccount(receiverAccountAddress)
        let receiver = recipient
            .getCapability(/public/BlockRecordsSingleCollection002)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
        self.minter.mintNFT(recipient: receiver, name: name, royaltyAddress: royaltyAddress, royaltyPercentage: royaltyPercentage, type: type, literation: literation, imageURL: imageUrl, audioURL: audioUrl)
    }
}
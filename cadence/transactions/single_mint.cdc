import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction(name: String, receiverAccountAddress: Address, royaltyAddress: Address, royaltyPercentage: UInt64, type: String, literation: String, imageUrl: String, audioUrl: String) {
    let minter: &BlockRecordsSingle.NFTMinter
    prepare(signer: AuthAccount) {
        self.minter = signer.borrow<&BlockRecordsSingle.NFTMinter>(from: /storage/BlockRecordsMinter002)!
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
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsUser from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS

transaction(
    type: String,
    name: String,
    literation: String,
    image: String, 
    audio: String,
    copiesCount: Int,
    payoutAddresses: [Address],
    payoutPercentFees: [UFix64],
    receiverAddress: Address
){
    let user: &BlockRecordsUser.User
    let receiverCollection: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.user = signer.borrow<&BlockRecordsUser.User>(from: BlockRecordsUser.UserStoragePath)
            ?? panic("could not get user resource")
        self.receiverCollection = getAccount(receiverAddress).getCapability(BlockRecordsSingle.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("could not get receiver reference to the NFT Collection")
    }

    pre {
        payoutAddresses.length == payoutPercentFees.length : "must have an equal number of payout addresses and percentages"
    }

    execute {
        let payouts: [BlockRecords.Payout] = []
        var i = 0
        while i < payoutAddresses.length {
            let address = payoutAddresses[i]
            let percentFee = payoutPercentFees[i]
            let fusdReceiver = getAccount(address).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
            let payout = BlockRecords.Payout(receiver: fusdReceiver, percentFee: percentFee)
            payouts.append(payout)
        }

        // create release
        let releaseID = self.user.createRelease(
            type: type,
            name: name,
            literation: literation,
            image: image, 
            audio: audio,
            copiesCount: copiesCount,
            payouts: payouts
        )

        // todo: probably should move this to a different transaction
        // mint singles for release
        self.user.mintReleaseSingles(releaseID: releaseID, count: copiesCount, receiverCollection: self.receiverCollection)
    }
}
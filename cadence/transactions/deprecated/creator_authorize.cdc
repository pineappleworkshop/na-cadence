import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// creates a new release collection for creator and saves to storage
// then, creates a new revocable release collection capability and saves to private storage
// after, gives the revocable capability to the creator

transaction(newCreatorAddress: Address) {
    prepare(account: AuthAccount) {
        // get creator capability receiver
        let creator = getAccount(newCreatorAddress)
        let creatorReceiver = creator.getCapability<&{BlockRecordsSingle.CreatorPublic}>(BlockRecordsSingle.CreatorPublicPath).borrow() 
            ?? panic("Could not borrow capability receiver")

        // get service acct FUSD vault
        let fusdVault = account.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver) 

        // create unique storage path for Release Collection
        let releaseCollStoragePath = /storage/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS
        let releaseCollection <- BlockRecordsSingle.createReleaseCollection(marketplaceVault: fusdVault, marketplaceFee: BlockRecordsSingle.Fee)
        account.save(<- releaseCollection, to: releaseCollStoragePath)

        // create unique private path for Release Collection so that we can revoke the capability if
        // creator violates the agreement
        let releaseCollPrivPath = /private/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS
        if account.getCapability<&BlockRecordsSingle.ReleaseCollection>(releaseCollPrivPath).check() {
            panic("unique creator release collection private path already exists")
        }
        account.link<&BlockRecordsSingle.ReleaseCollection>(releaseCollPrivPath, target: releaseCollStoragePath)

        // add release capability to creator so that they may create releases and mint NFTs
        let releaseCollectionCap = account.getCapability<&BlockRecordsSingle.ReleaseCollection>(releaseCollPrivPath)
        creatorReceiver.addCapability(cap: releaseCollectionCap)
    }
}
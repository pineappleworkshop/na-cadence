import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// creates a new release collection for creator and saves to storage
// then, creates a new revocable release collection capability and saves to private storage
// after, gives the revocable capability to the creator

transaction(
    creatorStageName: String,
    creatorLegalName: String,
    creatorImageURL: String,
    creatorAddress: Address 
) {
    prepare(account: AuthAccount) {

        // get creator capability receiver
        let creator = getAccount(creatorAddress)
        let creatorReceiver = creator.getCapability<&{BlockRecordsRelease.CreatorPublic}>(BlockRecordsRelease.CreatorPublicPath).borrow() ?? panic("Could not borrow capability receiver")

        // create a unique storage path for release collection
        // create a new release collection
        // save to storage
        let releaseCollStoragePath = /storage/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS
        let releaseCollection <- account.getCapability<&BlockRecordsMarketplace.Admin>(BlockRecordsMarketplace.AdminPrivatePath).borrow()!.createReleaseCollection(
            creatorStageName: creatorStageName,
            creatorLegalName: creatorLegalName,
            creatorImageURL: creatorImageURL,
            creatorAddress: creatorAddress
        )
        account.save(<- releaseCollection, to: releaseCollStoragePath)

        // create unique private path for Release Collection so that we can revoke the capability if
        // creator violates the agreement
        let releaseCollPrivPath = /private/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS
        if account.getCapability<&BlockRecordsRelease.ReleaseCollection>(releaseCollPrivPath).check() {
            panic("unique creator release collection private path already exists")
        }
        account.link<&BlockRecordsRelease.ReleaseCollection>(releaseCollPrivPath, target: releaseCollStoragePath)

        // add release capability to creator so that they may create releases and mint NFTs
        let releaseCollectionCap = account.getCapability<&BlockRecordsRelease.ReleaseCollection>(releaseCollPrivPath)
        creatorReceiver.addCapability(cap: releaseCollectionCap, address: creatorAddress)

        let marketplaceCap = account.getCapability<&BlockRecordsMarketplace.Marketplace>(BlockRecordsMarketplace.MarketplacePrivatePath).borrow()!
        marketplaceCap.addReleaseCollectionCapability(cap: releaseCollectionCap)
    }
}
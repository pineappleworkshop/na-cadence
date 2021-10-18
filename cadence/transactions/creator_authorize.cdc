import BlockRecordsUser from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// creates a new release collection for creator and saves to storage
// then, creates a new revocable release collection capability and saves to private storage
// after, gives the revocable capability to the creator

transaction(
    name: String,
    description: String,
    logo: String,
    banner: String,
    website: String,
    socialMedias: [String],
    creatorAddress: Address
) {
    prepare(account: AuthAccount) {
        // get creator capability receiver
        let creator = getAccount(creatorAddress)
        let user = creator.getCapability<&{BlockRecordsUser.UserPublic}>(BlockRecordsUser.UserPublicPath).borrow() 
            ?? panic("could not borrow capability receiver")

        // get admin resource
        let admin = account.getCapability<&BlockRecordsMarketplace.Admin>(BlockRecordsMarketplace.AdminPrivatePath).borrow()
            ?? panic("could not borrow admin resource")

        // todo:
        // create a unique storage path for release collection
        // create a new release collection & save to storage
        let releaseCollStoragePath = /storage/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS
        let releaseCollection <- admin.createReleaseCollection(
            name: "",
            description: "",
            logo: "",
            banner: "",
            website: "",
            socialMedias: [
                "",
                ""
            ]
        )
        account.save(<- releaseCollection, to: releaseCollStoragePath)

        // create unique private path for Release Collection so that we can revoke the capability if
        // creator violates the agreement
        let releaseCollPrivPath = /private/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS
        if account.getCapability<&BlockRecordsRelease.Collection>(releaseCollPrivPath).check() {
            panic("unique creator release collection private path already exists")
        }
        account.link<&BlockRecordsRelease.Collection>(releaseCollPrivPath, target: releaseCollStoragePath)

        // add owner release collection capability to creator so that they may create releases and mint NFTs
        let ownerCollectionCap = account.getCapability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionOwner}>(releaseCollPrivPath)
        user.addReleaseCollectionCapability(cap: ownerCollectionCap)

        // add public release collection capability to the marketplace so we can keep track of our
        // releases centrally
        let publicCollectionCap = account.getCapability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionPublic}>(releaseCollPrivPath)
        let marketplaceCap = account.getCapability<&BlockRecordsMarketplace.Marketplace>(BlockRecordsMarketplace.MarketplacePrivatePath).borrow()!
        marketplaceCap.addReleaseCollection(releaseCollectionCapability: publicCollectionCap, address: creatorAddress)
    }
}
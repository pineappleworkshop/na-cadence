import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction(newCreatorAddress: Address) {
    prepare(account: AuthAccount) {
        let newCreator = getAccount(newCreatorAddress)
        let newCreatorReceiver = newCreator.getCapability<&{BlockRecordsSingle.CreatorPublic}>(BlockRecordsSingle.CreatorPublicPath)
                .borrow() ?? panic("Could not borrow capability receiver")

        // create a unique, revocable private path for the creator
        // todo: this is potentially unsafe and unreliable, we should use something like a "broker"
        // to keep track of creator's paths; however, this should be sufficient for now
        let uniqueCreatorPrivatePath = /private/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS

        if account.getCapability<&BlockRecordsSingle.ReleaseCollection>(uniqueCreatorPrivatePath).check() {
            panic("capability already exists")
        }
        account.link<&BlockRecordsSingle.ReleaseCollection>(uniqueCreatorPrivatePath, target: BlockRecordsSingle.ReleaseCollectionStoragePath)

        let releaseCollectionCap = account.getCapability<&BlockRecordsSingle.ReleaseCollection>(uniqueCreatorPrivatePath)
        newCreatorReceiver.addCapability(cap: releaseCollectionCap)
    }
}
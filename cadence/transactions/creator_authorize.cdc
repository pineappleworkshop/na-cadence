import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS

transaction(newCreatorAddress: Address) {
    prepare(account: AuthAccount) {
        let newCreator = getAccount(newCreatorAddress)
        let newCreatorReceiver = newCreator.getCapability<&{BlockRecordsSingle.CreatorPublic}>(/public/BlockRecordsCreator002)
                .borrow() ?? panic("Could not borrow admin client")

        let releaseCap = account.getCapability<&BlockRecordsSingle.ReleaseCollection>(/private/BlockRecordsReleaseCollection002)

        newCreatorReceiver.addCapability(cap: releaseCap)
    }
    // prepare(account: AuthAccount) {
    //     let newCreator = getAccount(newCreatorAddress)
    //     let newCreatorReceiver = newCreator.getCapability<&{BlockRecordsSingle.CreatorPublic}>(BlockRecordsSingle.CreatorPublicPath)
    //             .borrow() ?? panic("Could not borrow admin client")

    //     let releaseCap = account.getCapability<&BlockRecordsSingle.ReleaseCollection>(BlockRecordsSingle.ReleaseCollectionPrivatePath)

    //     newCreatorReceiver.addCapability(cap: releaseCap)
    // }
}
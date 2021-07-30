import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction(newCreatorAddress: Address) {
    prepare(account: AuthAccount) {
        let newCreator = getAccount(newCreatorAddress)
        let newCreatorReceiver = newCreator.getCapability<&{BlockRecordsSingle.CreatorPublic}>(BlockRecordsSingle.CreatorPublicPath)
                .borrow() ?? panic("Could not borrow capability receiver")

        // create a unique, revocable private path for the creator
        let uniqueCreatorPath =  BlockRecordsSingle.CreatorPrivatePathPrefix.concat(newCreatorAddress.toString())
        let uniqueCreatorPrivatePath = /private/uniqueCreatorPath

        account.link<&BlockRecordsSingle.ReleaseCollection>(uniqueCreatorPrivatePath, target: BlockRecordsSingle.ReleaseCollectionStoragePath)

        let releaseCap = account.getCapability<&BlockRecordsSingle.ReleaseCollection>(uniqueCreatorPrivatePath)
        newCreatorReceiver.addCapability(cap: releaseCap)
    }
}
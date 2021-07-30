import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction(creatorAddress: Address) {
    prepare(account: AuthAccount) {
        
        // create a unique, revocable private path for the creator
        // todo: this is potentially unsafe and unreliable, we should use something like a "broker"
        // to keep track of creator's paths; however, this should be sufficient for now
        let uniqueCreatorPrivatePath = /private/BlockRecordsReleaseCollectionCREATOR_ACCOUNT_ADDRESS

        if !account.getCapability<&BlockRecordsSingle.ReleaseCollection>(uniqueCreatorPrivatePath).check() {
            panic("capability does not exist")
        }

        account.unlink(uniqueCreatorPrivatePath)
    }
}
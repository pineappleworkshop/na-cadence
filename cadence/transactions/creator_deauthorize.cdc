import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction(newCreatorAddress: Address) {
    prepare(account: AuthAccount) {
        let uniqueCreatorPath =  BlockRecordsSingle.CreatorPrivatePathPrefix.concat(newCreatorAddress.toString())
        let uniqueCreatorPrivatePath = /private/uniqueCreatorPath
        account.unlink(uniqueCreatorPath)
    }
}
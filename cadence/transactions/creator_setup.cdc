import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction {
    prepare(account: AuthAccount) {
        account.save(<- BlockRecordsSingle.createCreator(), to: BlockRecordsSingle.CreatorStoragePath)
        account.link<&BlockRecordsSingle.Creator{BlockRecordsSingle.CreatorPublic}>(BlockRecordsSingle.CreatorPublicPath, target: BlockRecordsSingle.CreatorStoragePath)
    }
}
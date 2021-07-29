import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS

transaction {
    prepare(account: AuthAccount) {
        account.save(<- BlockRecordsSingle.createCreator(), to: /storage/BlockRecordsCreator002)
        account.link<&{BlockRecordsSingle.CreatorPublic}>(/public/BlockRecordsCreator002, target: /storage/BlockRecordsCreator002)
    }

    // prepare(account: AuthAccount) {
    //     account.save(<- BlockRecordsSingle.createCreator(), to: BlockRecordsSingle.CreatorStoragePath)
    //     account.link<&{BlockRecordsSingle.CreatorPublic}>(BlockRecordsSingle.CreatorPublicPath, target: BlockRecordsSingle.CreatorStoragePath)
    // }
}
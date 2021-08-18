import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS

transaction {
	prepare(account: AuthAccount) {
		account.save(<- BlockRecordsRelease.createCreator(), to: BlockRecordsRelease.CreatorStoragePath)
		account.link<&BlockRecordsRelease.Creator{BlockRecordsRelease.CreatorPublic}>(BlockRecordsRelease.CreatorPublicPath, target: BlockRecordsRelease.CreatorStoragePath)
	}
}
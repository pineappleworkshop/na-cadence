import BlockRecordsSaleListing from 0xSERVICE_ACCOUNT_ADDRESS

transaction(id: UInt64) {
	prepare(account: AuthAccount) {
		let listing <- account.borrow<&BlockRecordsSaleListing.Collection>(from: BlockRecordsSaleListing.CollectionStoragePath)!.remove(id: id)
		destroy listing
	}
}
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsSaleListing from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(id: UInt64, marketCollectionAddress: Address) {
	let buyerVault: @FungibleToken.Vault
	let BlockRecordsNFTCollection: &BlockRecordsNFT.Collection{NonFungibleToken.Receiver}
	let marketCollection: &BlockRecordsSaleListing.Collection{BlockRecordsSaleListing.CollectionPublic}

	prepare(signer: AuthAccount) {
		self.marketCollection = getAccount(marketCollectionAddress).getCapability<&BlockRecordsSaleListing.Collection{BlockRecordsSaleListing.CollectionPublic}>(BlockRecordsSaleListing.CollectionPublicPath)!.borrow()
			?? panic("Could not borrow market collection from market address")

	let saleListing = self.marketCollection.borrowSaleListing(id: id)
		?? panic("No item with that ID")

	let price = saleListing.price

	let mainFUSDVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
		?? panic("Cannot borrow FUSD vault from acct storage")

	self.buyerVault <- mainFUSDVault.withdraw(amount: price)

	self.BlockRecordsNFTCollection = signer.borrow<&BlockRecordsNFT.Collection{NonFungibleToken.Receiver}>(from: BlockRecordsNFT.CollectionStoragePath) 
		?? panic("Cannot borrow BlockRecordsNFT collection receiver from acct")
	}

	execute {
		self.marketCollection.purchase(
			id: id,
			buyerCollection: self.BlockRecordsNFTCollection,
			buyerPayment: <- self.buyerVault
		)
	}
}
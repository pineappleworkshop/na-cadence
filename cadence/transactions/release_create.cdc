import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsNFT from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS

transaction(
	type: String,
	name: String,
	literation: String,
	imageURL: String, 
	audioURL: String,
	copiesCount: UInt64,
	payoutAddress: Address,
	payoutPercentFee: UFix64,
	receiverAddress: Address,
){
	let creator: &BlockRecordsRelease.Creator
	let receiverCollection: &{NonFungibleToken.CollectionPublic}

	prepare(signer: AuthAccount) {
		self.creator = signer.borrow<&BlockRecordsRelease.Creator>(from: BlockRecordsRelease.CreatorStoragePath)!
		self.receiverCollection = signer.getCapability(BlockRecordsNFT.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()
			?? panic("Could not get receiver reference to the NFT Collection")
	}

	execute {
		let payoutFUSDVault = getAccount(payoutAddress).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)! 

		self.creator.createRelease(
			type: type,
			name: name,
			literation: literation,
			imageURL: imageURL, 
			audioURL: audioURL,
			copiesCount: copiesCount,
			fusdVault: payoutFUSDVault,
			percentFee: payoutPercentFee,
			receiverCollection: self.receiverCollection
		)
	}
}
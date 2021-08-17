
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

// miscellaneous structs

pub contract BlockRecords{
		
		//events
		//
		pub event ContractInitialized()

		pub struct Payout {
			// the vault that  on the payout will be distributed to
			pub let fusdVault: Capability<&{FungibleToken.Receiver}>

			// percentage percentFee of the sale that will be paid out to the marketplace vault
			pub let percentFee: UFix64 

			init(
				fusdVault: Capability<&{FungibleToken.Receiver}>,
				percentFee: UFix64
			){
				self.fusdVault = fusdVault
				self.percentFee = percentFee
			}
		}

		// the creator's profile info
		pub struct CreatorProfile {

			// creator's stage name or pseudonym
			pub var stageName: String

			// creator's legal full name
			pub var legalName: String

			// creator's desired profile picture url
			pub var imageURL: String

			// creator's account address
			// this can be changed if the creator loses their credentials.
			// just unlink the private capability and create a new one,
			// then update creator profile struct in release collection.
			// NOTE: it is important to keep this reference in the release collection resource *only*
			// so there won't be discrepencies downstream if the creator's address changes
			pub var address: Address

			init(
				stageName: String, 
				legalName: String,
				imageURL: String,
				address: Address
			){
				self.stageName = stageName
				self.legalName = legalName
				self.imageURL = imageURL
				self.address = address
			}
		}

	init() {
		emit ContractInitialized()
	}
}

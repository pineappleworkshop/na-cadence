import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS

transaction(
  name: String,
  description: String,
  type: String,
  payoutAddress: Address,
  payoutPercentFee: UFix64
){
    let creator: &BlockRecordsRelease.Creator
    
    prepare(signer: AuthAccount) {
        self.creator = signer.borrow<&BlockRecordsRelease.Creator>(from: BlockRecordsRelease.CreatorStoragePath)!
    }

    execute {
      let payoutFUSDVault = getAccount(payoutAddress).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)! 
      let percentFee = 0.05

      self.creator.createRelease(
        name: name,
        description: description,
        type: type,
        fusdVault: payoutFUSDVault,
        percentFee: percentFee
      )
    }
}
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS

transaction(
  royaltyAddress: Address,
  royaltyFee: UFix64
){
    let creator: &BlockRecordsSingle.Creator
    
    prepare(signer: AuthAccount) {
        self.creator = signer.borrow<&BlockRecordsSingle.Creator>(from: BlockRecordsSingle.CreatorStoragePath)!
    }

    execute {
      let royaltyAccount = getAccount(royaltyAddress)
      let royaltyVault = royaltyAccount.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)! 

      self.creator.createRelease(
        royaltyVault: royaltyVault,
        royaltyFee: royaltyFee
      )
    }
}
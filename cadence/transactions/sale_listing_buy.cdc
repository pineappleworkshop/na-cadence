import FungibleToken from FUNGIBLE_TOKEN_CONTRACT_ADDRESS
import NonFungibleToken from NFT_CONTRACT_ADDRESS
import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarket from SERVICE_ACCOUNT_ADDRESS
import FUSD from FUSD_CONTRACT_ADDRESS

transaction(id: UInt64, marketCollectionAddress: Address) {
  let buyerVault: @FungibleToken.Vault
  let BlockRecordsSingleCollection: &BlockRecordsSingle.Collection{NonFungibleToken.Receiver}
  let marketCollection: &BlockRecordsMarket.Collection{BlockRecordsMarket.CollectionPublic}

  prepare(signer: AuthAccount) {
    self.marketCollection = getAccount(marketCollectionAddress)
        .getCapability<&BlockRecordsMarket.Collection{BlockRecordsMarket.CollectionPublic}>(
            BlockRecordsMarket.CollectionPublicPath
        )!
        .borrow()
        ?? panic("Could not borrow market collection from market address")
    let saleListing = self.marketCollection.borrowSaleListing(id: id)
                ?? panic("No item with that ID")
    let price = saleListing.price
    let mainFUSDVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
        ?? panic("Cannot borrow FUSD vault from acct storage")
    self.buyerVault <- mainFUSDVault.withdraw(amount: price)
    self.BlockRecordsSingleCollection = signer.borrow<&BlockRecordsSingle.Collection{NonFungibleToken.Receiver}>(
        from: BlockRecordsSingle.CollectionStoragePath
    ) ?? panic("Cannot borrow BlockRecordsSingle collection receiver from acct")
  }
  
  execute {
      self.marketCollection.purchase(
          id: id,
          buyerCollection: self.BlockRecordsSingleCollection,
          buyerPayment: <- self.buyerVault
      )
  }
}
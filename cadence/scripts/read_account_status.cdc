import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarket from SERVICE_ACCOUNT_ADDRESS

// todo: dev only, these contracts will exist in a different location on testnet/mainnet
import NonFungibleToken from NFT_CONTRACT_ADDRESS
import FungibleToken from FUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from FUSD_CONTRACT_ADDRESS

pub fun hasFUSD(_ address: Address): Bool {
  let receiver: Bool = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)
    .check()

  let balance: Bool = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
    .check()

  return receiver && balance
}

// todo: this seems to be failing
pub fun hasBlockRecordsSingles(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&BlockRecordsSingle.Collection{BlockRecordsSingle.BlockRecordsSingleCollectionPublic}>(BlockRecordsSingle.CollectionPublicPath)
    .check()
}

pub fun hasBlockRecordsMarket(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&BlockRecordsMarket.Collection{BlockRecordsMarket.CollectionPublic}>(BlockRecordsMarket.CollectionPublicPath)
    .check()
}

// todo: check for minting capability

pub fun main(address: Address): {String: Bool} {
  let ret: {String: Bool} = {}
  ret["FUSD"] = hasFUSD(address)
  ret["BlockRecordsSingle"] = hasBlockRecordsSingles(address)
  ret["BlockRecordsMarket"] = hasBlockRecordsMarket(address)
  return ret
}
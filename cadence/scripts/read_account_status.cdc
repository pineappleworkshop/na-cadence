import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarket from 0xSERVICE_ACCOUNT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

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
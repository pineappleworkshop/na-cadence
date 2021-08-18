import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

pub fun main(): UFix64 {
    let account = getAccount(0xTARGET_ADDRESS)

    let vaultRef = account
        .getCapability(/public/fusdBalance)!.borrow<&FUSD.Vault{FungibleToken.Balance}>()
            ?? panic("Could not borrow Balance capability")

    return vaultRef.balance
}
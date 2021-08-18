/**

## This is for development testing only

*/

import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

transaction(amount: UFix64, receiverAddress: Address) {
    let minterRef: @FUSD.Minter

    prepare(signer: AuthAccount) { 
        let admin = signer.borrow<&FUSD.Administrator>(from: /storage/fusdAdmin)!
        self.minterRef <- admin.createNewMinter()
    }

    execute {
        let recipient = getAccount(receiverAddress)

        let receiver = recipient.getCapability(/public/fusdReceiver)!.borrow<&{FungibleToken.Receiver}>()
            ?? panic("Could not get receiver reference to the FUSD Vault")

        let vault <- self.minterRef.mintTokens(amount:amount)
        receiver.deposit(from: <- vault)
        destroy self.minterRef
    }
}
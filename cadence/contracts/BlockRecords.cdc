
import NonFungibleToken from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS

/**

BlockRecords Core Contract

share structs, models, etc...

**/

pub contract BlockRecords {

    //events
    //
    pub event ContractInitialized()

    pub struct Payout {
        
        // the vault that on the payout will be distributed to
        pub let receiver: Capability<&{FungibleToken.Receiver}>

        // percentage percentFee of the sale that will be paid out to the fusd vault
        pub let percentFee: UFix64 

        init(
            receiver: Capability<&{FungibleToken.Receiver}>,
            percentFee: UFix64
        ){
            self.receiver = receiver
            self.percentFee = percentFee
        }
    }

    init() {
        emit ContractInitialized()
    }
}


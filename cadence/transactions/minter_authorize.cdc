import NonFungibleToken from 0xNON_FUNGIBLE_TOKEN_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction {
    prepare(signer: AuthAccount) {
    // Create a new minter
    let minter <- BlockRecordsSingle.createNFTMinter()
    // save it to the account
    signer.save(<-minter, to: /storage/BlockRecordsMinter002)
    }
}
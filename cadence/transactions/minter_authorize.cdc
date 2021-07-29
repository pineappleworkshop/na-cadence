import NonFungibleToken from NFT_CONTRACT_ADDRESS
import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS

transaction {
    prepare(signer: AuthAccount) {
    // Create a new minter
    let minter <- BlockRecordsSingle.createNFTMinter()
    // save it to the account
    signer.save(<-minter, to: /storage/BlockRecordsMinter002)
    }
}
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS

transaction {

    prepare(custodyProvider: AuthAccount) {

        let minter <- BlockRecordsSingle.createNFTMinter()

        custodyProvider.save(
            <-minter, 
            to: BlockRecordsSingle.MinterStoragePath,
        )
            
        // create new capability receiver
        custodyProvider.link<&BlockRecordsSingle.NFTMinter{BlockRecordsSingle.NFTMinterPublic}>(
            BlockRecordsSingle.MinterPublicPath,
            target: BlockRecordsSingle.MinterStoragePath
        )
    }
}
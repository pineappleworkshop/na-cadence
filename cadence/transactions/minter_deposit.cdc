import BlockRecordsSingle from SERVICE_ACCOUNT_ADDRESS

/// token admin signs this transaction to deposit a capability
/// into a custody provider's account that allows them to
/// create a minter

transaction(custodyProviderAddress: Address) {

    prepare(admin: AuthAccount) {

        let custodyProvider = getAccount(custodyProviderAddress)
            
        let capabilityReceiver = custodyProvider.getCapability
            <&BlockRecordsSingle.MinterCreator{BlockRecordsSingle.MinterCreatorPublic}>
            (BlockRecordsSingle.MinterCreatorPublicPath)!
            .borrow() ?? panic("Could not borrow capability receiver reference")

        let tokenAdminCollection = admin
            .getCapability<&BlockRecordsSingle.NFTMinter>(/private/NFTMinter)!

        capabilityReceiver.addCapability(cap: NFTMinter)
    }
}
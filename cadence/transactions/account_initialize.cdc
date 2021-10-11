import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS
import BlockRecordsSingle from 0xSERVICE_ACCOUNT_ADDRESS
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import FUSD from 0xFUSD_CONTRACT_ADDRESS
import BlockRecordsStorefront from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsUser from 0xSERVICE_ACCOUNT_ADDRESS

transaction {
    prepare(acct: AuthAccount) {
        // create single collection
        if acct.borrow<&BlockRecordsSingle.Collection>(from: BlockRecordsSingle.CollectionStoragePath) == nil {
            let collection <- BlockRecordsSingle.createEmptyCollection()
            acct.save(<- collection, to: BlockRecordsSingle.CollectionStoragePath)
            acct.unlink(BlockRecordsSingle.CollectionPublicPath)
            acct.link<&{NonFungibleToken.CollectionPublic, BlockRecordsSingle.CollectionPublic}>(
                BlockRecordsSingle.CollectionPublicPath,
                target: BlockRecordsSingle.CollectionStoragePath
            )    
        }
            
        // create fusd vault
        // todo: what should these paths be? what if a user already has an fusd vault?
        let fusdVaultStoragePath = /storage/fusdVault
        let fusdVaultReceiverPublicPath = /public/fusdReceiver
        let fusdBalancePublicPath = /public/fusdBalance
        if acct.borrow<&FUSD.Vault>(from: fusdVaultStoragePath) == nil {
            acct.save(<- FUSD.createEmptyVault(), to: fusdVaultStoragePath)
            acct.link<&FUSD.Vault{FungibleToken.Receiver}>(
                fusdVaultReceiverPublicPath,
                target: fusdVaultStoragePath
            )
            acct.link<&FUSD.Vault{FungibleToken.Balance}>(
                fusdBalancePublicPath,
                target: fusdVaultStoragePath
            )
        }
        
        // create storefront
        if acct.borrow<&BlockRecordsStorefront.Storefront>(from: BlockRecordsStorefront.StorefrontStoragePath) == nil {
            let storefront <- BlockRecordsStorefront.createStorefront() as! @BlockRecordsStorefront.Storefront
            acct.save(<- storefront, to: BlockRecordsStorefront.StorefrontStoragePath)
            acct.link<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>(
                BlockRecordsStorefront.StorefrontPublicPath, 
                target: BlockRecordsStorefront.StorefrontStoragePath
            )
            acct.link<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontManager}>(
                BlockRecordsStorefront.StorefrontManagerPath, 
                target: BlockRecordsStorefront.StorefrontStoragePath
            )
        }

        // list storefront in marketplace
        let storefrontCap = acct.getCapability<&BlockRecordsStorefront.Storefront{BlockRecordsStorefront.StorefrontPublic}>(BlockRecordsStorefront.StorefrontPublicPath)
        let marketplace = getAccount(0xSERVICE_ACCOUNT_ADDRESS).getCapability<&BlockRecordsMarketplace.Marketplace{BlockRecordsMarketplace.MarketplacePublic}>(BlockRecordsMarketplace.MarketplacePublicPath)!.borrow()!
        marketplace.listStorefront(storefrontCapability: storefrontCap)

        // create user profile
        if acct.borrow<&BlockRecordsUser.User>(from: BlockRecordsUser.UserStoragePath) == nil {
            let user <- BlockRecordsUser.createUser(
                name: "robbie_wasabi", 
                description: "Block Records Developer",
                allowStoringFollowers: true,
                tags: [
                    "developer",
                    "collector"
                ]
            ) as! @BlockRecordsUser.User
            acct.save(<- user, to: BlockRecordsUser.UserStoragePath)
            acct.link<&BlockRecordsUser.User{BlockRecordsUser.UserPublic}>(
                BlockRecordsUser.UserPublicPath, 
                target: BlockRecordsUser.UserStoragePath
            )
        }
    }
}
// @ignore
import FungibleToken from 0xFUNGIBLE_TOKEN_CONTRACT_ADDRESS
import BlockRecordsMarketplace from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecordsRelease from 0xSERVICE_ACCOUNT_ADDRESS
import BlockRecords from 0xSERVICE_ACCOUNT_ADDRESS
import NonFungibleToken from 0xNFT_CONTRACT_ADDRESS

/** 

## BlockRecords Users represent collectors or creators using the BlockRecords platform

## Users

create a user profile: name, description, avatar, banner, tags, etc...

link multiple Wallets, Resource Collections

follow other users

users who own a Resource Collection Capability are able to create releases

## TODO:

similarly to how the Marketplace lists storefronts and release collections, users
users should be able to do the same

## Heavily Inspired By: 

https://flow-view-source.com/testnet/account/0xba1132bc08f82fe2/contract/Ghost

https://github.com/versus-flow/versus-contracts/blob/master/contracts/Profile.cdc

**/

pub contract BlockRecordsUser {
    //events
    //
    pub event ContractInitialized()
        
    // user follows another user
    pub event Follow(follower: Address, following: Address, tags: [String])

    // user unfollows another user
    pub event Unfollow(follower: Address, unfollowing: Address)

    // user verifies something
    pub event Verification(account: Address, message: String)


    // named paths
    //
    pub let UserPublicPath: PublicPath
    pub let UserStoragePath: StoragePath

    /* 
    Represents a Fungible token wallet with a name and a supported type.
    */
    pub struct Wallet {
        pub let name: String
        pub let receiver: Capability<&{FungibleToken.Receiver}>
        pub let balance: Capability<&{FungibleToken.Balance}>
        pub let accept: Type
        pub let tags: [String]

        init(
            name: String,
            receiver: Capability<&{FungibleToken.Receiver}>,
            balance: Capability<&{FungibleToken.Balance}>,
            accept: Type,
            tags: [String]
        ) {
            self.name = name
            self.receiver = receiver
            self.balance = balance
            self.accept = accept
            self.tags = tags
        }
    }

    /*
        Represent a collection of a Resource that you want to expose
        use "type" and "instanceOf" for now
    */
    pub struct ResourceCollection {
        pub let collection: Capability
        pub let tags: [String]
        pub let type: Type
        pub let name: String

        init(name: String, collection:Capability, type: Type, tags: [String]) {
            self.name = name
            self.collection = collection
            self.tags = tags
            self.type = type
        }
    }

    /*
        Resource collections are easily fetchable with the help of this profile
    */
    pub struct CollectionProfile{
        pub let tags: [String]
        pub let type: String
        pub let name: String

        init(_ collection: ResourceCollection){
            self.name = collection.name
            self.type = collection.type.identifier
            self.tags = collection.tags
        }
    }

    /*
        A link that you could add to your profile
    */
    pub struct Link {
        pub let url: String
        pub let title: String
        pub let type: String

        init(title: String, type: String, url: String) {
            self.url = url
            self.title = title
            self.type = type
        }
    }

    /*
        Information about a connection between one profile and another.
    */
    pub struct FollowerStatus {
        pub let follower: Address
        pub let following: Address
        pub let tags: [String]

        init(follower: Address, following: Address, tags: [String]) {
            self.follower = follower
            self.following = following 
            self.tags = tags
        }
    }

    pub struct WalletProfile {
        pub let name: String
        pub let balance: UFix64
        pub let accept:  String
        pub let tags: [String] 

        init(_ wallet: Wallet) {
            self.name = wallet.name
            self.balance = wallet.balance.borrow()?.balance ?? 0.0 
            self.accept = wallet.accept.identifier
            self.tags = wallet.tags
        }
    }

    pub struct UserProfile {
        pub let address: Address
        pub let name: String
        pub let description: String
        pub let tags: [String]
        pub let avatar: String
        pub let banner: String
        pub let links: [Link]
        pub let wallets: [WalletProfile]
        pub let collections: [CollectionProfile]
        pub let following: [FollowerStatus]
        pub let followers: [FollowerStatus]
        pub let allowStoringFollowers: Bool

        init(
            address: Address,
            name: String,
            description: String, 
            tags: [String],
            avatar: String,
            banner: String, 
            links: [Link],
            wallets: [WalletProfile],
            collections: [CollectionProfile],
            following: [FollowerStatus],
            followers: [FollowerStatus],
            allowStoringFollowers:Bool
        ) {
            self.address = address
            self.name = name
            self.description = description
            self.tags = tags
            self.avatar = avatar
            self.banner = banner
            self.links = links
            self.collections = collections
            self.wallets = wallets
            self.following = following
            self.followers = followers
            self.allowStoringFollowers = allowStoringFollowers
        }
    }

    pub resource interface UserPublic {
        pub fun getName(): String
        pub fun getDescription(): String
        pub fun getTags(): [String]
        pub fun getAvatar(): String
        pub fun getCollections(): [ResourceCollection] 
        pub fun isFollowing(_ address: Address): Bool
        pub fun getFollowers(): [FollowerStatus]
        pub fun getFollowing(): [FollowerStatus]
        pub fun getWallets(): [Wallet]
        pub fun getLinks(): [Link]
        pub fun deposit(from: @FungibleToken.Vault)
        pub fun supportedFungibleTokenTypes(): [Type]
        pub fun asProfile(): UserProfile
        pub fun isBanned(_ val: Address): Bool
        pub fun isCreator(): Bool

        // a public function to be called by the BlockRecords Marketplace Admin
        pub fun addReleaseCollectionCapability(cap: Capability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionOwner}>)
        
        access(contract) fun internal_addFollower(_ val: FollowerStatus)
        access(contract) fun internal_removeFollower(_ address: Address) 
    }
    
    pub resource interface UserOwner {
        pub fun setName(_ val: String) {
            pre {
                val.length <= 16: "Name must be 16 or less characters"
            }
        }

        pub fun setAvatar(_ val: String){
            pre {
                val.length <= 255: "Avatar must be 255 characters or less"
            }
        }

        pub fun setTags(_ val: [String])  {
            pre {
                BlockRecordsUser.verifyTags(tags: val, tagLength:10, tagSize:3) : "cannot have more then 3 tags of length 10"
            }
        }   

        //validate length of description to be 255 or something?
        pub fun setDescription(_ val: String) {
            pre {
                val.length <= 255: "Description must be 255 characters or less"
            }
        }

        pub fun follow(_ address: Address, tags:[String]) {
            pre {
                BlockRecordsUser.verifyTags(tags: tags, tagLength:10, tagSize:3) : "cannot have more then 3 tags of length 10"
            }
        }
        pub fun unfollow(_ address: Address)

        pub fun removeCollection(_ val: String)
        pub fun addCollection(_ val: ResourceCollection)

        pub fun addWallet(_ val : Wallet) 
        pub fun removeWallet(_ val: String)
        pub fun setWallets(_ val: [Wallet])

        pub fun addLink(_ val: Link)
        pub fun removeLink(_ val: String)

        // verify that this user has signed something.
        pub fun verify(_ val: String) 

        // a user must be able to remove a follower since this data in your account is added there by another user
        pub fun removeFollower(_ val: Address)

        // manage bans
        pub fun addBan(_ val: Address)
        pub fun removeBan(_ val: Address)
        pub fun getBans(): [Address]

        // set if user is allowed to store followers or now
        pub fun setAllowStoringFollowers(_ val: Bool)

        // create release and add to release collection
        pub fun createRelease(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: Int,
            payouts: [BlockRecords.Payout]
        ): UInt64 

        // remove release collection capability from user account
        // will prevent the user from creating releases until a new one is added
        pub fun removeReleaseCollectionCapability()
    }

    pub resource User: UserPublic, UserOwner, FungibleToken.Receiver {
        access(self) var name: String
        access(self) var description: String
        access(self) var avatar: String
        access(self) var banner: String
        access(self) var tags: [String]
        access(self) var followers: {Address: FollowerStatus}
        access(self) var bans: {Address: Bool}
        access(self) var following: {Address: FollowerStatus}
        access(self) var collections: {String: ResourceCollection}
        access(self) var wallets: [Wallet]
        access(self) var links: {String: Link}
        access(self) var allowStoringFollowers: Bool

        // capability to a BlockRecords Release Collection in a Marketplace
        access(account) var releaseCollectionCapability: Capability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionOwner}>?

        init(
            name: String,
            description: String, 
            allowStoringFollowers: Bool, 
            tags: [String]
        ) {
            self.name = name
            self.description = description
            self.tags = tags
            self.avatar = "" // no default User picture
            self.banner = ""
            self.followers = {}
            self.following = {}
            self.collections = {}
            self.wallets = []
            self.links = {}
            self.allowStoringFollowers = allowStoringFollowers
            self.bans = {}
            self.releaseCollectionCapability = nil
        }

        // return the user as a profile
        pub fun asProfile(): UserProfile {
            let wallets: [WalletProfile] = []
            for w in self.wallets {
                wallets.append(WalletProfile(w))
            }

            let collections: [CollectionProfile] = []
            for c in self.getCollections() {
                collections.append(CollectionProfile(c))
            }

            return UserProfile(
                address: self.owner!.address,
                name: self.getName(),
                description: self.getDescription(),
                tags: self.getTags(),
                avatar: self.getAvatar(),
                banner: self.getBanner(),
                links: self.getLinks(),
                wallets: wallets, 
                collections: collections,
                following: self.getFollowing(),
                followers: self.getFollowers(),
                allowStoringFollowers: self.allowStoringFollowers
            )
        }

        // to be called by a BlockRecords Marketplace Admin
        pub fun addReleaseCollectionCapability(cap: Capability<&BlockRecordsRelease.Collection{BlockRecordsRelease.CollectionOwner}>) {
            pre {
                cap.check() : "invalid capability"
                self.releaseCollectionCapability == nil : "capability already set"
            }
            self.releaseCollectionCapability = cap

            // todo: emit event

            // let releaseCollection = self.releaseCollectionCapability!.borrow()!

            // let creator = releaseCollection.creatorProfile

            // todo: rename name as name
            // emitted when a creator is granted the capability to a collection,
            // allowing them to mint BlockRecords NFTs
            // emit Event(type: "collection_capability_added", metadata: {
            //     "collection_id": releaseCollection.id.toString(),
            //     "creator_stage_name": creator.stageName,
            //     "creator_legal_name": creator.name,
            //     "creator_img_url": creator.image,
            //     "creator_address": creator.address.toString()
            // })
        }

        // create release
        pub fun createRelease(
            type: String,
            name: String, 
            literation: String, 
            image: String, 
            audio: String,
            copiesCount: Int,
            payouts: [BlockRecords.Payout],
        ): UInt64 {
            pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
            }
            let rc = self.releaseCollectionCapability!.borrow()!
            let releaseID = rc.createAndAddRelease(
                type: type,
                name: name, 
                literation: literation, 
                image: image, 
                audio: audio,
                copiesCount: copiesCount,
                payouts: payouts
            )
            return releaseID
        }

        pub fun mintReleaseSingles(releaseID: UInt64, count: Int, receiverCollection: &{NonFungibleToken.CollectionPublic}) {
            pre {
                self.releaseCollectionCapability != nil: "not an authorized creator"
            }
            let rc = self.releaseCollectionCapability!.borrow()!
            let release = rc.borrowRelease(id: releaseID)
            // let release = rc.releases[releaseID]! as! &BlockRecordsRelease.Release
            release.mintSingles(count: count, receiverCollection: receiverCollection)
        }

        // remove release collection capability
        pub fun removeReleaseCollectionCapability() {
            self.releaseCollectionCapability = nil
        }

        // we can infer that a user is a creator if they have a release collection capability
        pub fun isCreator(): Bool{
            return self.releaseCollectionCapability != nil
        }

        pub fun addBan(_ val: Address) { 
            self.bans[val] = true
        }
        
        pub fun removeBan(_ val: Address) { 
            self.bans.remove(key: val) 
        }
        
        pub fun getBans(): [Address] { 
            return self.bans.keys 
        }
        
        pub fun isBanned(_ val: Address): Bool { 
            return self.bans.containsKey(val)
        }

        pub fun setAllowStoringFollowers(_ val: Bool) {
            self.allowStoringFollowers=val
        }

        pub fun verify(_ val:String) {
            emit Verification(account: self.owner!.address, message:val)
        }

        pub fun getLinks(): [Link] {
            return self.links.values
        }

        pub fun addLink(_ val: Link) {
            self.links[val.title]=val
        }

        pub fun removeLink(_ val: String) {
            self.links.remove(key: val)
        }
        
        pub fun supportedFungibleTokenTypes(): [Type] { 
            let types: [Type] =[]
            for w in self.wallets {
                if !types.contains(w.accept) {
                    types.append(w.accept)
                }
            }
            return types
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            for w in self.wallets {
                if from.isInstance(w.accept) {
                    w.receiver.borrow()!.deposit(from: <- from)
                    return
                }
            } 
            let identifier = from.getType().identifier
            destroy from
            panic("could not find a supported wallet for:".concat(identifier))
        }

        pub fun getWallets(): [Wallet] { 
            return self.wallets
        }
        
        pub fun addWallet(_ val: Wallet) { 
            self.wallets.append(val) 
        }
        
        pub fun removeWallet(_ val: String) {
            let numWallets=self.wallets.length
            var i=0
            while(i < numWallets) {
                if self.wallets[i].name== val {
                    self.wallets.remove(at: i)
                    return
                }
                i=i+1
            }
        }

        pub fun setWallets(_ val: [Wallet]) { 
            self.wallets = val 
        }

        pub fun removeFollower(_ val: Address) {
            self.followers.remove(key:val)
        }

        pub fun isFollowing(_ address: Address): Bool {
            return self.following.containsKey(address)
        }

        pub fun getName(): String { 
            return self.name 
        }

        pub fun getDescription(): String { 
            return self.description
        }
        
        pub fun getTags(): [String] { 
            return self.tags
        }
        
        pub fun getAvatar(): String { 
            return self.avatar 
        }
        
        pub fun getBanner(): String { 
            return self.banner 
        }
        
        pub fun getFollowers(): [FollowerStatus] { 
            return self.followers.values 
        }
        
        pub fun getFollowing(): [FollowerStatus] { 
            return self.following.values 
        }
        
        pub fun setName(_ val: String) { 
            self.name = val 
        }

        pub fun setAvatar(_ val: String) { 
            self.avatar = val 
        }
        
        pub fun setBanner(_ val: String) { 
            self.banner = val 
        }
        
        pub fun setDescription(_ val: String) { 
            self.description = val
        }
        
        pub fun setTags(_ val: [String]) { 
            self.tags = val 
        }

        pub fun removeCollection(_ val: String) { 
            self.collections.remove(key: val)
        }
        
        pub fun addCollection(_ val: ResourceCollection) { 
            self.collections[val.name] = val
        }
        
        pub fun getCollections(): [ResourceCollection] { 
            return self.collections.values
        }

        pub fun follow(_ address: Address, tags: [String]) {
            let profile = BlockRecordsUser.find(address)
            let owner = self.owner!.address
            let status = FollowerStatus(follower: owner, following: address, tags: tags)

            self.following[address] = status
            profile.internal_addFollower(status)
            emit Follow(follower: owner, following: address, tags:tags)
        }
        
        pub fun unfollow(_ address: Address) {
            self.following.remove(key: address)
            BlockRecordsUser.find(address).internal_removeFollower(self.owner!.address)
            emit Unfollow(follower: self.owner!.address, unfollowing: address)
        }
        
        access(contract) fun internal_addFollower(_ val: FollowerStatus) {
            if self.allowStoringFollowers && !self.bans.containsKey(val.follower) {
                self.followers[val.follower] = val
            }
        }
        
        access(contract) fun internal_removeFollower(_ address: Address) {
            if self.followers.containsKey(address) {
                self.followers.remove(key: address)
            }
        }
    }

    pub fun find(_ address: Address): &{BlockRecordsUser.UserPublic} {
        return getAccount(address)
        .getCapability<&{BlockRecordsUser.UserPublic}>(BlockRecordsUser.UserPublicPath)!
        .borrow()!
    }
    
    pub fun createUser(
        name: String, 
        description: String, 
        allowStoringFollowers: Bool, 
        tags: [String]
    ): @BlockRecordsUser.User {
        pre {
            BlockRecordsUser.verifyTags(tags: tags, tagLength: 10, tagSize: 3) : "cannot have more then 3 tags of length 10"
            name.length <= 16: "Name must be 16 or less characters"
            description.length <= 255: "Descriptions must be 255 or less characters"
        }
        return <- create BlockRecordsUser.User(
                name: name, 
                description: description, 
                allowStoringFollowers: allowStoringFollowers, 
                tags: tags
            )
    }

    pub fun verifyTags(tags : [String], tagLength: Int, tagSize: Int): Bool {
        if tags.length > tagSize {
            return false
        }

        for t in tags {
            if t.length > tagLength {
                return false
            }
        }
        return true
    }

    init() {
        self.UserPublicPath = /public/BlockRecordsUser
        self.UserStoragePath = /storage/BlockRecordsUser

        emit ContractInitialized()
    }    
}

# na-cadence

## Development Setup

```bash
# install flow cli
$ brew install flow-cli
# install dependencies
$ make init
```

---

## Start Emulator (to run emulator locally)

```bash
# start the emulator
$ make flow-emulator
```

---

## Deploy/Update All Contracts

```bash
# deploy all contracts
$ make flow-deploy-contracts
# update all contracts
$ make flow-update-contracts
```

---

## Deploy/Update Contracts Individually

```bash
# deploy NonFungibleToken
$ make flow-deploy-nft-contract
# deploy FungibleToken
$ make flow-deploy-ft-contract
# deploy FUSD
$ make flow-deploy-fusd-contract
# deploy BlockRecordsSingle (dependencies: NonFungibleToken)
$ make flow-deploy-single-contract
# deploy BlockRecordsMarket (dependencies: BlockRecordsSingle, FungibleToken, NonFungibleToken, FUSD)
$ make flow-deploy-market-contract
```

---

## Start Service

```bash
# start service
$ make dev
```

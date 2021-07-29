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
# deploy all contracts to emulator
$ make flow-deploy-contracts-emulator
# deploy all contracts to testnet
$ make flow-deploy-contracts-testnet
# deploy all contracts to mainnet
$ make flow-deploy-contracts-mainnet

# update all contracts on emulator 
$ make flow-update-contracts-emulator
# update all contracts on testnet
$ make flow-update-contracts-testnet
# update all contracts on mainnet 
$ make flow-update-contracts-mainnet
```

---

## Start Service

```bash
# start service
$ make dev
```

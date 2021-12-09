# Block Records Smart Contracts and Tests

All of the cadence contracts and tests for the BlockRecords platform.

## Setup Development Environment

```bash
# install flow cli
$ brew install flow-cli

# install dependencies
$ make init

# create .env file
$ cp .env.default .env
```

---

## Start Flow Emulator

```bash
# start the emulator
$ make flow-emulator
```

---

## Deploy All Contracts

```bash
# deploy all contracts to emulator
$ make flow-deploy-contracts
```

---

## Run Tests

in order to run the tests, make sure to:

1. setup development environment
2. start flow emulator
3. deploy all contracts

```bash
# run tests
$ make tests
```

---

## Run Service

```bash
# start service
$ make run
```

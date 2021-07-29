service := na-cadence
version := 0.0.4
docker_org := pineappleworkshop
cluster := pw-dev
docker-image := gcr.io/${docker_org}/${service}:${version}
root := $(abspath $(shell pwd))
port := 3444

list:
	@grep '^[^#[:space:]].*:' Makefile | grep -v ':=' | grep -v '^\.' | sed 's/:.*//g' | sed 's/://g' | sort

bootstrap:
	go mod init $(service)
	make init

init:
	go mod tidy

build:
	go build main.go

build-cli-linux:
	# must move binary to root
	cd ./cli && env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o cli-cicd

build-cli-osx:
	go build main.go

dev:
	go run main.go

test:
	go test -v ./...

flow-emulator:
	flow emulator start

flow-deploy-contracts-emulator:
	go run cli/main.go deploy-contracts --env emulator

flow-deploy-contracts-testnet:
	go run cli/main.go deploy-contracts --env testnet

flow-deploy-contracts-mainnet:
	go run cli/main.go deploy-contracts --env mainnet

flow-update-contracts-emulator:
	go run cli/main.go update-contracts --env emulator

flow-update-contracts-testnet:
	go run cli/main.go update-contracts --env testnet

flow-update-contracts-mainnet:
	go run cli/main.go update-contracts --env mainnet

flow-deploy-nft-contract:
	go run cli/main.go deploy-nft-contract

flow-update-nft-contract:
	go run cli/main.go update-nft-contract

flow-deploy-single-contract:
	go run cli/main.go deploy-single-contract

flow-update-single-contract:
	go run cli/main.go update-single-contract

flow-deploy-market-contract:
	go run cli/main.go deploy-market-contract

flow-update-market-contract:
	go run cli/main.go update-market-contract

flow-update-all-contracts:
	make flu

docker-build:
	docker build -t $(docker-image) .

docker-dev:
	make docker-build
	make docker-run

docker-push:
	docker push $(docker-image)

docker-run:
	@docker run -itp $(port):$(port)  $(docker-image)

test-workstation:
	go test ./test/... --env=workstation -v 3

test-dev:
	go test ./test/... --env=dev -v 3

test-stage:
	go test ./test/... --env=stage -v 3

test-prod:
	go test ./test/... --env=prod -v 3

bumpversion-patch:
	bumpversion patch --allow-dirty

bumpversion-minor:
	bumpversion minor --allow-dirty

bumpversion-major:
	bumpversion major --allow-dirty

purge:
	go clean
	rm -rf $(root)/vendor

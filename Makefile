include .env

service := na-cadence
version := 0.0.6
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

run:
	ENV=local
	go run main.go

run-workstation:
	ENV=workstation
	go run main.go

flow-emulator:
	flow emulator start

flow-deploy-contracts:
	go run cli/main.go deploy-contracts --env emulator

flow-deploy-contracts-testnet:
	go run cli/main.go deploy-contracts --env testnet

flow-deploy-contracts-mainnet:
	go run cli/main.go deploy-contracts --env mainnet

docker-build:
	docker build -t $(docker-image) .

docker-dev:
	make docker-build
	make docker-run

docker-push:
	docker push $(docker-image)

docker-run:
	@docker run -itp $(port):$(port)  $(docker-image)

tests:
	go test ./...

tests-workstation:
	go test ./test/... --env=workstation -v 3

tests-dev:
	go test ./test/... --env=dev -v 3

tests-stage:
	go test ./test/... --env=stage -v 3

tests-prod:
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

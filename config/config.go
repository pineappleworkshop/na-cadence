package config

import (
	"errors"
	"fmt"
	"os"

	"github.com/spf13/viper"
	_ "github.com/spf13/viper/remote"
)

var Conf *Config

// init config function at build
func InitConf() {
	Conf = new(Config)
	Conf.setEnv()
	if err := Conf.setupViper(); err != nil {
		fmt.Println(err)
	}
	Conf.setupConfig()
}

// service config generate at build
type Config struct {
	Env                             string
	ConsulHost                      string
	ConsulPort                      string
	FlowAccessNode                  string
	FlowServiceAccountPrivateKey    string
	FlowServiceAccountAddress       string
	IPFSAccessNodeURL               string
	FUSDContractAddress             string
	FungibleTokenContractAddress    string
	NonFungibleTokenContractAddress string
}

// set environment
func (c *Config) setEnv() {
	var env = os.Getenv("ENV")
	if env == "" || env == WORKSTATION {
		c.Env = WORKSTATION
		c.ConsulHost = CONSUL_HOST_DEV
		c.ConsulPort = CONSUL_PORT_DEV
	} else if env == DEV {
		c.Env = DEV
		c.ConsulHost = CONSUL_HOST_CLUSTER
		c.ConsulPort = CONSUL_PORT_CLUSTER
	} else if env == STAGE {
		c.Env = STAGE
		c.ConsulHost = CONSUL_HOST_CLUSTER
		c.ConsulPort = CONSUL_PORT_CLUSTER
	} else if env == PROD {
		c.Env = PROD
		c.ConsulHost = CONSUL_HOST_CLUSTER
		c.ConsulPort = CONSUL_PORT_CLUSTER
	}
}

// setup viper to use consul as the remote config provider
func (c *Config) setupViper() error {
	consulURL := fmt.Sprintf("%s:%s", c.ConsulHost, c.ConsulPort)
	if err := viper.AddRemoteProvider("consul", consulURL, CONSUL_KV); err != nil {
		return err
	}
	viper.SetConfigType("json")
	if err := viper.ReadRemoteConfig(); err != nil {
		return err
	}

	return nil
}

// setup config with premise to either running service on cluster vs locally
func (c *Config) setupConfig() {
	ipfsAccessNodeURL, err := GetIPFSAccessNodeURL()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.IPFSAccessNodeURL = *ipfsAccessNodeURL

	flowAccessNode, err := GetFlowAccessNode()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.FlowAccessNode = *flowAccessNode

	flowServiceAccountAddress, err := GetFlowServiceAccountAddressess()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.FlowServiceAccountAddress = *flowServiceAccountAddress

	flowServiceAcctPrivateKey, err := GetFlowServiceAccountPrivateKey()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.FlowServiceAccountPrivateKey = *flowServiceAcctPrivateKey

	fusdContractAddress, err := GetFUSDContractAddress()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.FUSDContractAddress = *fusdContractAddress

	fungibleTokenContractAddress, err := GetFungibleTokenContractAddress()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.FungibleTokenContractAddress = *fungibleTokenContractAddress

	nonFungibleTokenContractAddress, err := GetNonFungibleTokenContractAddress()
	if err != nil {
		fmt.Println(err)
		return
	}
	c.NonFungibleTokenContractAddress = *nonFungibleTokenContractAddress
}

// get environment set at build
func (c *Config) GetEnv() string {
	return c.Env
}

// get jwt secret
func GetJwtSecret() (string, error) {
	if err := viper.ReadRemoteConfig(); err != nil {
		return "", nil
	}
	jwtSecret := viper.GetString("jwt_secret")
	return jwtSecret, nil
}

func GetIPFSAccessNodeURL() (*string, error) {
	pk := viper.GetString("ipfs_access_node_url")
	if pk == "" {
		return nil, errors.New("no ipfs access node url found")
	}
	return &pk, nil
}

func GetFlowAccessNode() (*string, error) {
	pk := viper.GetString("flow_access_node")
	if pk == "" {
		return nil, errors.New("no flow access node found")
	}
	return &pk, nil
}

func GetFlowServiceAccountAddressess() (*string, error) {
	pk := viper.GetString("flow_service_account_address")
	if pk == "" {
		return nil, errors.New("no flow service account address found")
	}
	return &pk, nil
}

func GetFlowServiceAccountPrivateKey() (*string, error) {
	pk := viper.GetString("flow_service_account_private_key")
	if pk == "" {
		return nil, errors.New("no flow service account private key found")
	}
	return &pk, nil
}

func GetFUSDContractAddress() (*string, error) {
	pk := viper.GetString("fusd_contract_address")
	if pk == "" {
		return nil, errors.New("no fusd contract address found")
	}
	return &pk, nil
}

func GetFungibleTokenContractAddress() (*string, error) {
	pk := viper.GetString("fungible_token_contract_address")
	if pk == "" {
		return nil, errors.New("no fungible token contract address found")
	}
	return &pk, nil
}

func GetNonFungibleTokenContractAddress() (*string, error) {
	pk := viper.GetString("non_fungible_token_contract_address")
	if pk == "" {
		return nil, errors.New("no non fungible token contract address found")
	}
	return &pk, nil
}

// get flow service account address
func GetFlowServiceAccountSecretKey() (*string, error) {
	serviceAccountSecretKey := viper.GetString("service_account_secret_key")
	if serviceAccountSecretKey == "" {
		return nil, errors.New("no service account secret key found")
	}
	return &serviceAccountSecretKey, nil
}

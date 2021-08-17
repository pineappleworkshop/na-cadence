package cmd

import (
	"fmt"
	"na-cadence/config"

	"github.com/spf13/cobra"
)

const (
	EMULATOR = "emulator"
	TESTNET  = "testnet"
	MAINNET  = "mainnet"
)

func init() {
	deployAllContractsCmd.Flags().StringVar(&env, "env", "", "specify environment: emulator, testnet, mainnet")
	rootCmd.AddCommand(deployAllContractsCmd)

	removeContractCmd.Flags().StringVar(&name, "name", "", "specify contract name")
	rootCmd.AddCommand(removeContractCmd)

	deployContract.Flags().StringVar(&name, "name", "", "specify contract name")
	rootCmd.AddCommand(deployContract)

	updateContract.Flags().StringVar(&name, "name", "", "specify contract name")
	rootCmd.AddCommand(updateContract)
}

var removeContractCmd = &cobra.Command{
	Use:   "remove-contract",
	Short: "remove contract from service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := RemoveContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, name)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}
	},
}

var deployContract = &cobra.Command{
	Use:   "deploy-contract",
	Short: "deploy contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		var contractFilePath string
		if name == NFT_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
		} else if name == FUNGIBLE_TOKEN_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == FUSD_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_FUSD_CONTRACT
		} else if name == BR_NFT_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_NFT_CONTRACT
		} else if name == BR_MARKETPLACE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT
		} else if name == BR_RELEASE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_RELEASE_CONTRACT
		} else if name == BR_SALE_LISTING_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_SALE_LISTING_CONTRACT
		} else if name == "" {
			fmt.Println("must specify contract name")
			return
		} else {
			fmt.Println("contract not found")
			return
		}

		result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, contractFilePath, name)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}
	},
}

var updateContract = &cobra.Command{
	Use:   "update-contract",
	Short: "update contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		var contractFilePath string

		if name == NFT_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
		} else if name == FUNGIBLE_TOKEN_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == FUSD_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_FUSD_CONTRACT
		} else if name == BR_NFT_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_NFT_CONTRACT
		} else if name == BR_MARKETPLACE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT
		} else if name == BR_RELEASE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_RELEASE_CONTRACT
		} else if name == BR_SALE_LISTING_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_SALE_LISTING_CONTRACT
		} else if name == "" {
			fmt.Println("must specify contract name")
			return
		} else {
			fmt.Println("contract not found")
			return
		}

		result, err := UpdateContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, contractFilePath, name)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}
	},
}

var deployAllContractsCmd = &cobra.Command{
	Use:   "deploy-contracts",
	Short: "deploy all contracts to service account",
	Run: func(cmd *cobra.Command, args []string) {
		if env == "" {
			fmt.Println("must specify the environment: emulator, testnet, mainnet")
			return
		}

		if env == EMULATOR {
			// NonFungibleToken
			result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NFT_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(result.Status.String())
			}

			// Fungibletoken
			result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(result.Status.String())
			}

			// FUSD
			result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(result.Status.String())
			}
		}

		// BlockRecordsNFT
		result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_NFT_CONTRACT, BR_NFT_CONTRACT_NAME)
		if err != nil {
			fmt.Println("error", err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}

		// BlockRecordsRelease
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_RELEASE_CONTRACT, BR_RELEASE_CONTRACT_NAME)
		if err != nil {
			fmt.Println("error", err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}

		// BlockRecordsMarketplace
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT, BR_MARKETPLACE_CONTRACT_NAME)
		if err != nil {
			fmt.Println("error", err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}

		// BlockRecordsSaleListing
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_SALE_LISTING_CONTRACT, BR_SALE_LISTING_CONTRACT_NAME)
		if err != nil {
			fmt.Println("error", err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}
	},
}

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

	updateAllContractsCmd.Flags().StringVar(&env, "env", "", "specify environment: emulator, testnet, mainnet")
	rootCmd.AddCommand(updateAllContractsCmd)

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
		var contractFileName string
		if name == "NonFungibleToken" || name == "nft" {
			contractFileName = NON_FUNGIBLE_TOKEN_CONTRACT_NAME
		} else if name == "FungibleToken" || name == "ft" {
			contractFileName = FUNGIBLE_TOKEN_CONTRACT_NAME
		} else if name == "FUSD" || name == "fusd" {
			contractFileName = FUSD_CONTRACT_NAME
		} else if name == "BlockRecordsSingle" || name == "single" {
			contractFileName = SINGLE_CONTRACT_NAME
		} else if name == "BlockRecordsMarket" || name == "market" {
			contractFileName = MARKET_CONTRACT_NAME
		} else if name == "" {
			fmt.Println("contract not found")
			return
		} else {
			fmt.Println("must specify contract name")
			return
		}
		result, err := RemoveContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, contractFileName)
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
		if name == "NonFungibleToken" || name == "nft" {
			contractFilePath = LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "FungibleToken" || name == "ft" {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "FUSD" || name == "fusd" {
			contractFilePath = LOCAL_FILE_PATH_FUSD_CONTRACT
		} else if name == "BlockRecordsSingle" || name == "single" {
			contractFilePath = LOCAL_FILE_PATH_SINGLE_CONTRACT
		} else if name == "BlockRecordsMarket" || name == "market" {
			contractFilePath = LOCAL_FILE_PATH_MARKET_CONTRACT
		} else if name == "" {
			fmt.Println("contract not found")
			return
		} else {
			fmt.Println("must specify contract name")
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
		if name == "NonFungibleToken" || name == "nft" {
			contractFilePath = LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "FungibleToken" || name == "ft" {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "FUSD" || name == "fusd" {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "BlockRecordsSingle" || name == "single" {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "BlockRecordsMarket" || name == "market" {
			contractFilePath = LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT
		} else if name == "" {
			fmt.Println("contract not found")
			return
		} else {
			fmt.Println("must specify contract name")
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
			result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
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

		// BlockRecordsSingle
		result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_SINGLE_CONTRACT, SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println("error", err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}

		// BlockRecordsMarket
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_MARKET_CONTRACT, MARKET_CONTRACT_NAME)
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

var updateAllContractsCmd = &cobra.Command{
	Use:   "update-contracts",
	Short: "update all contracts on service account",
	Run: func(cmd *cobra.Command, args []string) {
		if env == EMULATOR {
			// NonFungibleToken
			result, err := UpdateContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(result.Status.String())
			}

			// Fungibletoken
			result, err = UpdateContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(result.Status.String())
			}

			// FUSD
			result, err = UpdateContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(result.Status.String())
			}
		}

		// BlockRecordsSingle
		result, err := UpdateContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_SINGLE_CONTRACT, SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(result.Status.String())
		}

		// BlockRecordsMarket
		result, err = UpdateContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_MARKET_CONTRACT, MARKET_CONTRACT_NAME)
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

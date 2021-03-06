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

	// logging
	CONTRACT_DEPLOYED_SUCCESS_MESSAGE = " deployed successfully"
	CONTRACT_REMOVED_SUCCESS_MESSAGE  = " removed successfully"
	CONTRACT_UPDATED_SUCCESS_MESSAGE  = " updated successfully"
	CONTRACT_NOT_FOUND                = "contract not found"
)

func init() {
	deployAllContractsCmd.Flags().StringVar(&flowEnv, "env", "", "specify environment: emulator, testnet, mainnet")
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
			fmt.Println(name + CONTRACT_REMOVED_SUCCESS_MESSAGE)
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
		} else if name == BR_SINGLE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_SINGLE_CONTRACT
		} else if name == BR_MARKETPLACE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT
		} else if name == BR_RELEASE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_RELEASE_CONTRACT
		} else if name == BR_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_CONTRACT
		} else if name == BR_STOREFRONT_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_STOREFRONT_CONTRACT
		} else if name == BR_USER_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_USER_CONTRACT
		} else if name == "" {
			fmt.Println("must specify contract name")
			return
		} else {
			fmt.Println(CONTRACT_NOT_FOUND)
			return
		}

		result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, contractFilePath, name)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(name + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
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
		} else if name == BR_SINGLE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_SINGLE_CONTRACT
		} else if name == BR_MARKETPLACE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT
		} else if name == BR_RELEASE_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_RELEASE_CONTRACT
		} else if name == BR_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_CONTRACT
		} else if name == BR_STOREFRONT_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_STOREFRONT_CONTRACT
		} else if name == BR_USER_CONTRACT_NAME {
			contractFilePath = LOCAL_FILE_PATH_BR_USER_CONTRACT
		} else if name == "" {
			fmt.Println("must specify contract name")
			return
		} else {
			fmt.Println(CONTRACT_NOT_FOUND)
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
		if flowEnv == "" {
			fmt.Println("must specify the environment: emulator, testnet, mainnet")
			return
		}

		if flowEnv == EMULATOR {
			// NonFungibleToken
			result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NFT_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(NFT_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
			}

			// Fungibletoken
			result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(FUNGIBLE_TOKEN_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
			}

			// FUSD
			result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
			if err != nil {
				fmt.Println(err)
			}
			if result.Error != nil {
				fmt.Println(result.Error.Error())
			} else {
				fmt.Println(FUSD_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
			}
		}

		// BlockRecords
		result, err := DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_CONTRACT, BR_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(BR_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
		}

		// BlockRecordsSingle
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_SINGLE_CONTRACT, BR_SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(BR_SINGLE_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
		}

		// BlockRecordsRelease
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_RELEASE_CONTRACT, BR_RELEASE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(BR_RELEASE_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
		}

		// BlockRecordsStorefront
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_STOREFRONT_CONTRACT, BR_STOREFRONT_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(BR_STOREFRONT_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
		}

		// BlockRecordsMarketplace
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_MARKETPLACE_CONTRACT, BR_MARKETPLACE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(BR_MARKETPLACE_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
		}

		// BlockRecordsUser
		result, err = DeployContract(config.Conf.FlowServiceAccountAddress, config.Conf.FlowServiceAccountPrivateKey, LOCAL_FILE_PATH_BR_USER_CONTRACT, BR_USER_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		if result.Error != nil {
			fmt.Println(result.Error.Error())
		} else {
			fmt.Println(BR_USER_CONTRACT_NAME + CONTRACT_DEPLOYED_SUCCESS_MESSAGE)
		}
	},
}

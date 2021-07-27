package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

func init() {

	rootCmd.AddCommand(deployAllContractsCmd)
	rootCmd.AddCommand(updateAllContractsCmd)

	rootCmd.AddCommand(deployNonFunbileTokenContractCmd)
	rootCmd.AddCommand(updateNonFunbileTokenContractCmd)

	rootCmd.AddCommand(deplyFungibleTokenContractCmd)
	rootCmd.AddCommand(updateFungibleTokenContractCmd)

	rootCmd.AddCommand(deplyFUSDContractCmd)
	rootCmd.AddCommand(updateFUSDContractCmd)

	rootCmd.AddCommand(deploySingleContractCmd)
	rootCmd.AddCommand(updateSingleContractCmd)

	rootCmd.AddCommand(deployMarketContractCmd)
	rootCmd.AddCommand(updateMarketContractCmd)
}

var deployAllContractsCmd = &cobra.Command{
	Use:   "deploy-contracts",
	Short: "deploy all contracts to service account",
	Run: func(cmd *cobra.Command, args []string) {

		// todo: emulator only
		// NonFungibleToken
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// todo: emulator only
		// Fungibletoken
		result, err = DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// FUSD
		result, err = DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// BlockRecordsSingle
		result, err = DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_SINGLE_CONTRACT, SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// BlockRecordsMarket
		result, err = DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_MARKET_CONTRACT, MARKET_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

var updateAllContractsCmd = &cobra.Command{
	Use:   "update-contracts",
	Short: "update all contracts on service account",
	Run: func(cmd *cobra.Command, args []string) {

		// todo: emulator only
		// NonFungibleToken
		result, err := UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// todo: emulator only
		// Fungibletoken
		result, err = UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// FUSD
		result, err = UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// BlockRecordsSingle
		result, err = UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_SINGLE_CONTRACT, SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)

		// BlockRecordsMarket
		result, err = UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_MARKET_CONTRACT, MARKET_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

// EMULATOR ONLY
var deployNonFunbileTokenContractCmd = &cobra.Command{
	Use:   "deploy-nft-contract",
	Short: "deploy market contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

// EMULATOR ONLY
var updateNonFunbileTokenContractCmd = &cobra.Command{
	Use:   "update-nft-contract",
	Short: "update market contract on service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_NON_FUNGIBLE_TOKEN_CONTRACT, NON_FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

// EMULATOR ONLY
var deplyFungibleTokenContractCmd = &cobra.Command{
	Use:   "deploy-fusd-contract",
	Short: "deploy FUSD contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

// EMULATOR ONLY
var updateFungibleTokenContractCmd = &cobra.Command{
	Use:   "update-ft-contract",
	Short: "update fungible token contract on service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUNGIBLE_TOKEN_CONTRACT, FUNGIBLE_TOKEN_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

// EMULATOR ONLY
var deplyFUSDContractCmd = &cobra.Command{
	Use:   "deploy-fusd-contract",
	Short: "deploy FUSD contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

// EMULATOR ONLY
var updateFUSDContractCmd = &cobra.Command{
	Use:   "update-nft-contract",
	Short: "update market contract on service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_FUSD_CONTRACT, FUSD_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

var deploySingleContractCmd = &cobra.Command{
	Use:   "deploy-single-contract",
	Short: "deploy market contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_SINGLE_CONTRACT, SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

var updateSingleContractCmd = &cobra.Command{
	Use:   "update-single-contract",
	Short: "update single contract on service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_SINGLE_CONTRACT, SINGLE_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

var deployMarketContractCmd = &cobra.Command{
	Use:   "deploy-market-contract",
	Short: "deploy market contract to service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := DeployContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_MARKET_CONTRACT, MARKET_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

var updateMarketContractCmd = &cobra.Command{
	Use:   "update-market-contract",
	Short: "update market contract on service account",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := UpdateContract(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY, LOCAL_FILE_PATH_MARKET_CONTRACT, MARKET_CONTRACT_NAME)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(result)
	},
}

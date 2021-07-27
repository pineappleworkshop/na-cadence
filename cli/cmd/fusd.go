package cmd

import (
	"fmt"
	"na-cadence/config"

	"github.com/spf13/cobra"
)

func init() {
	readFUSDBalanceCmd.Flags().StringVar(&acctAddr, "addr", "", "specify account address")
	rootCmd.AddCommand(readFUSDBalanceCmd)
}

var readFUSDBalanceCmd = &cobra.Command{
	Use:   "fusd-balance",
	Short: "get fusd balance from account",
	Run: func(cmd *cobra.Command, args []string) {

		if acctAddr == "" {
			fmt.Println("must provide account address")
			return
		}

		result, err := ReadAccountFUSDBalance(config.Conf.FlowServiceAccountAddress, acctAddr)
		if err != nil {
			fmt.Println(err)
		}

		fmt.Println(result)

	},
}

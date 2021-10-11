package cmd

import (
	"fmt"
	"na-cadence/config"
	"na-cadence/scripts"

	"github.com/spf13/cobra"
)

func init() {
	getSinglesByAddressCMD.Flags().StringVar(&acctAddr, "acctAddr", "", "specify address")
	rootCmd.AddCommand(getSinglesByAddressCMD)
}

var getSinglesByAddressCMD = &cobra.Command{
	Use:   "get-singles",
	Short: "get all singles by account address",
	Run: func(cmd *cobra.Command, args []string) {
		result, err := scripts.GetSinglesByAccountAddress(config.Conf.FlowServiceAccountAddress, acctAddr)
		if err != nil {
			fmt.Println(err)
		}

		fmt.Printf("%v", result)
	},
}

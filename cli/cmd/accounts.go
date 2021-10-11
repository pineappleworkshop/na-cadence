package cmd

import (
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(authorizeMinterCMD)
}

var authorizeMinterCMD = &cobra.Command{
	Use:   "authorize-minter",
	Short: "authorize user account to mint nonfungible tokens",
	Run: func(cmd *cobra.Command, args []string) {
		// result, err := transactions.AuthorizeMinter(FLOW_SERVICE_ACCOUNT_ADDR, FLOW_SERVICE_ACCOUNT_PRIVATE_KEY)
		// if err != nil {
		// 	fmt.Println(err)
		// }
		// fmt.Println(result)
	},
}

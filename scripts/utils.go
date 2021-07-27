package scripts

import (
	"context"
	"na-cadence/config"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk/client"
	"google.golang.org/grpc"
)

func ExecuteScript(script []byte) (cadence.Value, error) {
	ctx := context.Background()
	c, err := client.New(config.Conf.FlowAccessNode, grpc.WithInsecure())
	if err != nil {
		return nil, err
	}

	byteScript := script

	result, err := c.ExecuteScriptAtLatestBlock(ctx, byteScript, nil)
	if err != nil {
		return nil, err
	}

	return result, nil
}

package cdc

import "github.com/onflow/cadence"

func StringToHex(s string) string {
	return "0x" + s
}

func GetValueFromKey(key string, kvs []cadence.KeyValuePair) (value string) {
	for _, kv := range kvs {
		if key == string(kv.Key.(cadence.String)) {
			value := kv.Value.(cadence.String)
			return string(value)
		}
	}
	return ""
}

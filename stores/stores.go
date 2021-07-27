package stores

import (
	"na-cadence/config"
)

var DB *Store

func InitDbs() {
	DB = setupStores()
	if err := DB.Mongo.Connect(); err != nil {
		panic(err)
	}
}

type Store struct {
	Mongo *Mongo
}

func setupStores() *Store {
	return &Store{
		Mongo: NewMongo(config.Conf.MongoRC),
	}
}

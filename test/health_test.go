package test

// import (
// 	. "github.com/smartystreets/goconvey/convey"
// 	"na-cadence/config"
// 	"net/http"
// 	"testing"
// )

// // This tests the /health endpoint
// func TestHealth(t *testing.T) {
// 	Convey("If services exists", t, func() {
// 		So(ENV, ShouldNotEqual, "")
// 		So(BASE_URL, ShouldNotEqual, "")

// 		Convey("%s: When consuming the /health endpoint", func() {
// 			res, body, err := Health(BASE_URL)
// 			So(err, ShouldBeNil)
// 			So(res, ShouldNotBeNil)
// 			So(body, ShouldNotBeNil)

// 			Convey("Then it should return a 200 with the correct body", func() {
// 				So(res.StatusCode, ShouldEqual, http.StatusOK)
// 				So(body["service"].(string), ShouldEqual, "na-cadence")
// 				So(int(body["status"].(float64)), ShouldEqual, http.StatusOK)
// 				So(body["version"].(string), ShouldEqual, config.VERSION)
// 			})
// 		})
// 	})
// }

package test

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

// This struct can be used as the expected param for the
// Request function (WU 2020-08-13)
type RequestParams struct {
	BaseURL string
	Method  string
	Body    RequestBody
	URIs    []string
	Headers map[string]string
}

type RequestBody struct {
	Email             string `json:"email,omitempty"`
	Password          string `json:"password,omitempty"`
	UID               string `json:"uid,omitempty"`
	ReturnSecureToken *bool  `json:"returnSecureToken,omitempty"`
	FBToken           string `json:"fb_token,omitempty"`
	Role              string `json:"role,omitempty"`
	Disabled          *bool  `json:"disabled,omitempty"`
}

// Request takes a base URL, the HTTP method, a body, request headers and a list of uris.
// Builds and executes the HTTP request
// Returns an HTTP response, the parsed body and an error
func Request(params RequestParams, respM interface{}) (*http.Response, error) {
	url := params.BaseURL
	for _, uri := range params.URIs {
		url = fmt.Sprintf("%s%s", url, uri)
	}

	client := &http.Client{}
	reqBody, err := json.Marshal(params.Body)
	if err != nil {
		return nil, err
	}
	inputBody := strings.NewReader(string(reqBody))
	req, err := http.NewRequest(params.Method, url, inputBody)
	if err != nil {
		return nil, err
	}
	if params.Headers != nil {
		for headerName, headerValue := range params.Headers {
			req.Header.Add(headerName, headerValue)
		}
	}

	res, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	respBody, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	// todo: remove, we wanna check error codes in the testing instead
	var resClone http.Response
	resClone = *res
	if resClone.StatusCode != 200 {
		return &resClone, errors.New("status not 200")
	}

	if err := json.Unmarshal(respBody, respM); err != nil {
		return nil, err
	}

	return &resClone, nil
}

// Health takes a base URL
// Executes a GET request to the /users/health endpoint
// Returns an HTTP response, the parsed body and an error
func Health(baseURL string) (*http.Response, map[string]interface{}, error) {
	// todo: maybe can make more dynamic let `GetReq` and all get requests can use this same method
	// todo: you could possibly set the `/url` in the tests instead of here
	params := RequestParams{
		BaseURL: baseURL,
		Method:  "GET",
		URIs:    []string{"/health"},
	}
	var respBody map[string]interface{}
	response, err := Request(params, &respBody)

	return response, respBody, err
}

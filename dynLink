// Dynamic BW Utilization
// Masum Z. Hasan
// Verizon
// September 2017

// Minimal error checking ...Need to do that

package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"time"
)

// Empty Tab : const
const (
	empty = ""
	tab   = "\t"
)

type LinkThresholdRegistration struct {
	Ofl3Statistics struct {
		GlobalParameters struct {
			MaximumWindow  int `json:"maximum-window"`
			SamplingPeriod int `json:"sampling-period"`
		} `json:"global-parameters"`
		StatRegistration []struct {
			RegistrationID string `json:"registration-id"`
			Notification   []struct {
				NotificationID string `json:"notification-id"`
				Window         int    `json:"window"`
				Threshold      struct {
					Crossing       string `json:"crossing"`
					Type           string `json:"type"`
					ThresholdValue int    `json:"threshold-value"`
				} `json:"threshold"`
			} `json:"notification"`
			LinkGroupID string `json:"link-group-id"`
		} `json:"stat-registration"`
	} `json:"ofl3-statistics"`
}

type UtilizationRequestInputBody struct {
	Input struct {
		RegistrationID string `json:"registration-id"`
		Window         string `json:"window"`
		ResponseType   string `json:"response-type"`
		ResponseUnits  string `json:"response-units"`
	} `json:"input"`
}

// DynamicBWUtil : Utilization Values: Dynamic BW Utilization Data from Controller
type DynamicBWUtil struct {
	Output struct {
		Summary struct {
			Value []struct {
				LinkID        string `json:"link-id"`
				LinkUtilValue int    `json:"link-util-value"`
			} `json:"value"`
		} `json:"summary"`
		Time   string `json:"time"`
		Window int    `json:"window"`
	} `json:"output"`
}

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

// gppd: GET/POST/PUT/DELETE
func SendRESTRequest(client *http.Client, gppd, url, usr, pwd string, body []byte) []byte {

	var respbody []byte

	req, err := http.NewRequest(gppd, url, bytes.NewBuffer(body))

	if err != nil {
		fmt.Printf("NewRequest Error %s\n", err)
	}

	req.Header.Add("Authorization", "Basic "+basicAuth(usr, pwd))
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("HTTPS error %s\n", err)
		os.Exit(1)
	} else {
		//respbody, _ := ioutil.ReadAll(resp.Body)
		// =, rather than := removes "declared, not used error"
		respbody, _ = ioutil.ReadAll(resp.Body)
	}

	/*
		// Debug
		var prettyJSON bytes.Buffer
		error := json.Indent(&prettyJSON, respbody, empty, tab)
		if error != nil {
			fmt.Println("JSON RESPONSE ERROR")
		}
		fmt.Println(string(prettyJSON.Bytes()))
	*/

	return respbody

}

func printUtilDataForDynBW(client *http.Client, usr, pwd string, ltreg []string) {

	utilURL := "http://10.100.16.151:8181/restconf/operations/ofl3-statistics:get-statistics"

	for i := range ltreg {
		input := UtilizationRequestInputBody{}
		input.Input.RegistrationID = ltreg[i]
		input.Input.Window = "5"
		input.Input.ResponseUnits = "link-utilization"
		input.Input.ResponseType = "individual"

		ltreginput, err := json.Marshal(&input)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		resp := SendRESTRequest(client, "POST", utilURL, usr, pwd, ltreginput)

		t := time.Now()
		timeNow := t.Format("Mon Jan _2 15:04:05 2006")

		dbw := DynamicBWUtil{}
		json.Unmarshal([]byte(string(resp)), &dbw)

		fmt.Println("|****************************************************************************|")
		for i := range dbw.Output.Summary.Value {
			prnt := fmt.Sprintf("| %s : %42s : %3d|", timeNow, dbw.Output.Summary.Value[i].LinkID, dbw.Output.Summary.Value[i].LinkUtilValue)
			fmt.Println("|----------------------------------------------------------------------------|")
			fmt.Println(prnt)

		}
		fmt.Println("|****************************************************************************|")
	}
}

func getLinkThresholdReg(client *http.Client, usr, pwd string) []string {

	getURL := "http://10.100.16.151:8181/restconf/config/ofl3-statistics:ofl3-statistics"

	resp := SendRESTRequest(client, "GET", getURL, usr, pwd, nil)

	ltregstruct := LinkThresholdRegistration{}
	json.Unmarshal(resp, &ltregstruct)

	ltreg := make([]string, len(ltregstruct.Ofl3Statistics.StatRegistration)+1)

	for i := range ltregstruct.Ofl3Statistics.StatRegistration {
		ltreg[i] = ltregstruct.Ofl3Statistics.StatRegistration[i].RegistrationID
	}

	return ltreg

}

func main() {

	client := &http.Client{}
	const usr = "admin"
	const pwd = "admin"

	fmt.Println("DYNAMIC BW UTILIZATION INFO FOR ALL 6 LINKS")
	fmt.Println()

	// forever loop
	for {
		fmt.Println("|****************************************************************************|")
		fmt.Println("|----------------------------------------------------------------------------|")

		// get link threshold reg API request should be replaced with intercepting message  vz-sdn.orchestrator.link-threshold-registration
		// Or when this message appears, get all current registration via API
		ltreg := getLinkThresholdReg(client, usr, pwd)
		printUtilDataForDynBW(client, usr, pwd, ltreg)

		fmt.Println("|----------------------------------------------------------------------------|")
		fmt.Println("|****************************************************************************|")
		time.Sleep(5 * time.Second)
	}

}

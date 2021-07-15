import ballerina/http;
import ballerina/io;

# Description
#
# + httpClient - Parameter Description  
public client class Client {

    public http:Client httpClient;

    public isolated function init(SpreadsheetConfiguration config) returns error? {
        http:ClientSecureSocket? socketConfig = config?.secureSocketConfig;
        self.httpClient = check new (BASE_URL, {
            auth: config.oauthClientConfig,
            secureSocket: socketConfig
        });  
    }

    remote isolated function createSpreadsheet( string name) returns error|string {
        json jsonPayload = {"properties": {"title": name}};
        json response = check sendRequestWithPayload(self.httpClient, SPREADSHEET_PATH, jsonPayload);
        json spreadsheetId = check response.spreadsheetId;
        return spreadsheetId.toString();
    }

    remote isolated function openSpreadsheetById(string spreadsheetId) returns error? {
        string spreadsheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId;
        json jsonResult = check sendRequest(self.httpClient, spreadsheetPath);
        io:println("");
    }

    remote isolated function addSheet(string spreadsheetId, string sheetName) returns string|error {
        map<json> payload = {"requests": [{"addSheet": {"properties": {}}}]};
        map<json> jsonSheetProperties = {};
        if (sheetName != "") {
            jsonSheetProperties["title"] = sheetName;
        }
        json[] requestsElement = <json[]>(payload["requests"].clone());
        map<json> firstRequestsElement = <map<json>>requestsElement[0];
        json value = check firstRequestsElement.addSheet;
        map<json> sheetElement = <map<json>>value;
        sheetElement["properties"] = jsonSheetProperties;
        string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + BATCH_UPDATE_REQUEST;
        json jsonresponse = check sendRequestWithPayload(self.httpClient, addSheetPath, payload);
        json jsonResponseValues = check jsonresponse.replies;
        json[] replies = <json[]>jsonResponseValues;
        json addSheet = check replies[0].addSheet;
        json createdSheetName = check addSheet.properties.title;
        return createdSheetName.toString();        
    }

    remote isolated function setRange(string spreadsheetId, string sheetName, 
                                      string a1Notation, (string|int|decimal)[][] values) returns error? {
        if (a1Notation == "") {
            return error("Invalid range notation");
        }
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string setValuePath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        setValuePath = setValuePath + string `${VALUE_INPUT_OPTION}`;
        http:Request request = new;
        json[][] jsonValues = [];
        int i = 0;
        foreach (string|int|decimal)[] value in values {
            int j = 0;
            json[] val = [];
            foreach string|int|decimal v in value {
                val[j] = v;
                j = j + 1;
            }
            jsonValues[i] = val;
            i = i + 1;
        }
        json jsonPayload = {"values": jsonValues};
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = check self.httpClient->put(<@untainted>setValuePath, request);
        int statusCode = httpResponse.statusCode;
        json jsonResult = check httpResponse.getJsonPayload();
    }

    remote isolated function getCell(string spreadsheetId, string sheetName, string a1Notation, 
                                 string? valueRenderOption = ()) returns string|error {
        int|string|decimal value = EMPTY_STRING;
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string getCellDataPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        getCellDataPath = getCellDataPath + ((valueRenderOption is ()) ? EMPTY_STRING : 
            string `${QUESTION_MARK}${VALUE_RENDER_OPTION}${valueRenderOption}`);
        json response = check sendRequest(self.httpClient, getCellDataPath);
        if (!(response.values is error)) {
            json jsonResponseValues = check response.values;
            json[] responseValues = <json[]>jsonResponseValues;
            json[] firstResponseValue = <json[]>responseValues[0];
            return firstResponseValue[0].toString();
        }
        return "";
    }

    remote isolated function getRangeData(string spreadsheetId, string sheetName,
                                      string a1Notation, string? valueRenderOption = ()) 
                                      returns string[][]|error {
        string[][] values = [];
        if (a1Notation == EMPTY_STRING) {
            return error("Invalid range notation");
        }
        string notation = sheetName + EXCLAMATION_MARK + a1Notation;
        string getSheetValuesPath = SPREADSHEET_PATH + PATH_SEPARATOR + spreadsheetId + VALUES_PATH + notation;
        getSheetValuesPath = getSheetValuesPath + ((valueRenderOption is ()) ? EMPTY_STRING : 
            string `${QUESTION_MARK}${VALUE_RENDER_OPTION}${valueRenderOption}`);
        json jsonresponse = check sendRequest(self.httpClient, getSheetValuesPath);
        if (!(jsonresponse.values is error)) {
            values = check convertToArray(jsonresponse);
        }
        return values;
    }
}

public type SpreadsheetConfiguration record {
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig oauthClientConfig;
    http:ClientSecureSocket secureSocketConfig?;
};




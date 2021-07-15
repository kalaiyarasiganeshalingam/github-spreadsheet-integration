import ballerina/http;

isolated function sendRequest(http:Client httpClient, string path) returns json|error {
    http:Response httpResponse = check httpClient->get(path);
    int statusCode = httpResponse.statusCode;
    json jsonResponse = check httpResponse.getJsonPayload();
    check validateStatusCode(jsonResponse, statusCode);
    return jsonResponse;
}

isolated function sendRequestWithPayload(http:Client httpClient, string path, json jsonPayload = ())
returns  json|error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(jsonPayload);
    }
    http:Response httpResponse = check httpClient->post(path, httpRequest);
    int statusCode = httpResponse.statusCode;
    json jsonResponse = check httpResponse.getJsonPayload();
    check validateStatusCode(jsonResponse, statusCode);
    return jsonResponse;
}

isolated function validateStatusCode(json response, int statusCode) returns error? {
    if (!(statusCode == http:STATUS_OK)) {
        return getSpreadsheetError(response);
    }
}

isolated function convertToArray(json jsonResponse) returns string[][]|error {
    string[][] values = [];
    int i = 0;
    json jsonResponseValues = check jsonResponse.values;
    json[] jsonValues = <json[]>jsonResponseValues.clone();
    foreach json value in jsonValues {
        json[] jsonValArray = <json[]>value;
        int j = 0;
        string[] val = [];
        foreach json v in jsonValArray {
            val[j] = v.toString();
            j = j + 1;
        }
        values[i] = val;
        i = i + 1;
    }
    return values;
}

isolated function getSpreadsheetError(json|error errorResponse) returns error {
  if (errorResponse is json) {
        return error(errorResponse.toString());
  } else {
        return errorResponse;
  }
}

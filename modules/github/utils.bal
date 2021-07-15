import ballerina/http;

isolated function getRepositoryIssueList(string repositoryOwnerName, string repositoryName,
                                         string date, string accessToken, http:Client graphQlClient,
                                         string? label) returns json|error {
    string stringQuery = getFormulatedStringQueryForGetIssueList(repositoryOwnerName, repositoryName, "closed",
                                                                 date, label);
    http:Request request = new;
    request.setHeader("Authorization", "token " + accessToken);
    json convertedQuery = check stringQuery.fromJsonString();
    //Set headers and payload to the request
    request.setJsonPayload(convertedQuery);
    http:Response response = check graphQlClient->post(EMPTY_STRING, request);

    //Check for empty payloads and errors
    return check response.getJsonPayload();
}

isolated function getFormulatedStringQueryForGetIssueList(string repositoryOwnerName, string repositoryName,
                                                          string state, string date, string? labelName) returns string {
    string query;
    if (labelName is string) {
       query = string `is:${state} is:issue label:${labelName} closed:${date}..${date} repo:${repositoryOwnerName}/${repositoryName}`;
    } else {
       query = string `is:${state} is:issue closed:${date}..${date} repo:${repositoryOwnerName}/${repositoryName}`;
    }
    return "{\"query\": \"query {\n" +
           "search(query: \\\"" + query + "\\\", type: ISSUE, first: 100) {\n" +
           "   issueCount\n" +
           "   }\n" +
           "}\"}";
}



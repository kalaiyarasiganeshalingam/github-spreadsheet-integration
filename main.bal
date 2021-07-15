import ballerina/io;
import ballerina/regex;
import github_spreadsheet_integration.github;
import github_spreadsheet_integration.gsheet;

configurable string sheet_refresh_token = ?;
configurable string sheet_client_id = ?;
configurable string sheet_client_secret = ?;
configurable string github_access_token = ?;

string repositoryOwner = "ballerina-platform";

gsheet:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: sheet_client_id,
        clientSecret: sheet_client_secret,
        refreshToken: sheet_refresh_token,
        refreshUrl: gsheet:REFRESH_URL
    }
};

github:Configuration config = {
    accessToken: github_access_token
};

public function main(string... args) returns error? {
    string columnName;
    string spreadsheetId;
    string sheetname;
    string date = io:readln(string `Enter the date[Format: YYYY-MM-DD] which will be used to get the count of closed issues: `);
    string isCreateSheet = io:readln(string `Do you create a new spreadsheet to store counts(Y|N): `);
    gsheet:Client gsheetClient = check new(spreadsheetConfig);
    if (isCreateSheet.equalsIgnoreCaseAscii("Yes") || isCreateSheet.equalsIgnoreCaseAscii("Y")) {
        spreadsheetId  = io:readln(string `Enter the spreadsheet name which is to be created: `);
        spreadsheetId = check gsheetClient->createSpreadsheet(spreadsheetId);
        sheetname = "Sheet1";
        check gsheetClient->setRange(spreadsheetId, sheetname, "A2:C96", check addRepoDetails());
        columnName = "D";
        io:println("New spreadsheet created successfully!\nSpreadsheet id: " + spreadsheetId +
                    "\nSheet name: ", sheetname);
    } else {
        spreadsheetId = io:readln(string `Enter the spreadsheet id to store counts : `);
        sheetname = io:readln(string `Enter the sheet name: `);
        columnName = io:readln(string `Enter the column name in the sheet to print the closed issue count: `);
    }
    string[][] repoDetails = check gsheetClient->getRangeData(spreadsheetId, sheetname, "B3:B96");
    string[][] totalCount = check getColsedIssueCounts(repoDetails, date);
    check gsheetClient->setRange(spreadsheetId, sheetname, string `${columnName}2:${columnName}96`, totalCount);
    io:println("Closed issue count updated successfully!");
}

function getColsedIssueCounts(string[][] entries, string date) returns string[][]|error {
    github:Client githubClient = check new (config);
    string[][] totalCount = [[date]];
    foreach string[] entry in entries {
        string[] count =[];
        string[] orgname = regex:split(entry[0], ":");
        json issueCount;
        if (orgname.length() > 1) {
            issueCount = check githubClient->getRepositoryIssueList(repositoryOwner, orgname[0], date, orgname[1]);
        } else {
            issueCount = check githubClient->getRepositoryIssueList(repositoryOwner, orgname[0], date);
        }
        count.push((check issueCount.data.search.issueCount).toString());
        totalCount.push(count);
    }
    return totalCount;
}

isolated function addRepoDetails() returns string[][]|error {
    string path = "data.txt";
    string[] listResult = check io:fileReadLines(path);
    string[][] records = [];
    foreach string item in listResult {
        records.push(regex:split(item, ","));
    }
    return records;
}

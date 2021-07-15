import ballerina/http;

public client class Client {

    string accessToken;
    http:Client githubGraphQlClient;

    public isolated function init(Configuration config) returns error? {
        self.accessToken = config.accessToken;
        self.githubGraphQlClient = check new(GIT_GRAPHQL_API_URL, config.clientConfig);
    }

    remote isolated function getRepositoryIssueList(string repositoryOwnerName, string repositoryName,
                                                    string date, string? label = ()) returns json|error {
        return getRepositoryIssueList(repositoryOwnerName, repositoryName, date,
                        self.accessToken, self.githubGraphQlClient, label);
    }
}

public type Configuration record {
    http:ClientConfiguration clientConfig = {};
    string accessToken;
};

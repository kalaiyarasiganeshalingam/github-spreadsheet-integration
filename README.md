# github-spreadsheet-integration

This project is used to get the number of issues resolved in every label of a GitHub repo on a given date and add that count in the spreadsheet.

## Prerequisites

* Ballerina Swan Lake Beta1 Installed

* Update the `config.toml` file with spreadsheet and github credentials.
    * Obtain spreadsheet credential
        * Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
        * Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
        * On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**.
        * Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
         [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the access token and refresh token).
        * Click **Create**. Your client ID and client secret appear. 
        * In a separate browser window or tab, visit [OAuth 2.0 Playground](https://developers.google.com/oauthplayground). 
          Click on the `OAuth 2.0 Configuration` icon in the top right corner and click on `Use your own OAuth credentials` and
          provide your `OAuth Client ID` and `OAuth Client Secret`.
        * Then click **Authorize APIs**.
        * When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the access token and refresh token.
    * To obtain github credential, see [Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) or [GitHub OAuth App token](https://docs.github.com/en/developers/apps/creating-an-oauth-app).
    
## Run the project

To run the example, move into the github-spreadsheet-integration project and execute the below command.

```$bal run```

It will build this project and then run it. When running this project, you need to give the spread sheet details and date by the terminal. 

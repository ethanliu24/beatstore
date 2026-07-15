# Development enviornment set up

## `.env`
The config in example should be enough for development. Make a `.env` file at root level and copy the contents from `.env.example` in it.
- `SECRET_KEY_BASE` is empty, check in `credentials:rails` make sure it exists.
  - If it does, either remove this from `.env` or copy the contents. This is sensitive information
  - If it does not, generate a new one

## `settings.local.yml`
This overrides default env config for personal local development, and is not tracked by version control.
Create the file `config/settings.local.yml` if haven't already.

### Stripe
1. Login to Stripe dashboard
2. Create sandbox environment

```yml
# settings.local.yml
stripe:
  public_key: "get this from stripe testing sandbox"
  secret_key: "get this from stripe testing sandbox"
  payments_webhook_secret: "get this from running stripe cli"
```

### Google

#### OAuth2 Customer Auth
1. Login to Google cloud console
2. Go to `OAuth > Clients`
3. Create a `Web Application` OAuth2 client
4. Add following URIs:
  - Authorized JavaScript Origins: `http://localhost:3000`
  - Authorized redirect URIs: `http://localhost:3000/auth/google_oauth2/callback`

```yml
# settings.local.yml
oauth2:
  google:
    client_id: "get this from the client created"
    client_secret: "get this from the client created"
```

#### Google API
1. Similar to section `Google OAuth Login`, create a `Web Application` OAuth client
2. Go to [Google OAuth Playground](https://developers.google.com/oauthplayground/) and add OAuth client credentials by ticking `Use your own OAuth credentials` in settings
3. Select needed API scopes, authorize and exchage the refresh token

Example [guide](https://docs.automationedge.com/plugins/advanced/4.4/Appendices/GoogleWorkspaceGenerateRefreshToken).

### Backup Google Drive
1. In section `Google API`, get refresh token with the following [scopes](https://developers.google.com/workspace/drive/api/reference/rest/v3/files/create):
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.appdata`
- `https://www.googleapis.com/auth/drive.file`
2. Log in to producer email's google drive and get the folder ids in the url for:
- `primary`
- `queue`
- `cable`
- `cache`
- `errors`

```yml
# settings.local.yml
backup:
  google_drive:
    folders:
      primay: "primary folder id"
      queue: "queue folder id"
      cable: "cable folder id"
      cache: "cache folder id"
      errors: "errors folder id"
```
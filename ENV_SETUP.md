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

```
# settings.local.yml
stripe:
  public_key: "get this from stripe testing sandbox"
  secret_key: "get this from stripe testing sandbox"
  payments_webhook_secret: "get this from running stripe cli"
```

### Google OAuth
1. Login to Google cloud console
2. Go to `OAuth > Clients`
3. Create a development OAuth client
4. Add following URIs:
  - Authorized JavaScript Origins: `http://localhost:3000`
  - Authorized redirect URIs: `http://localhost:3000/auth/google_oauth2/callback`

```
# settings.local.yml
oauth2:
  google:
    client_id: "get this from the client created"
    client_secret: "get this from the client created"
```

### Backup Google Drive
1. Log in to producer email's google drive and get the folder ids in the url for:
- primary
- queue
- errors

```
backup:
  google_drive:
    service_account: "<%= Rails.application.credentials.dig(:backup, :google_drive, :service_account) %>"
    folders:
      primay: "primary folder id"
      queue: "queue folder id"
      cable: "cable folder id"
      cache: "cache folder id"
      errors: "errors folder id"
```

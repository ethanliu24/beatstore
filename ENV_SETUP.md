# Development enviornment set up

## `settings.local.yml`
This overrides default env config for personal local development, and is not tracked by version control.
Create the file `config/settings.local.yml` if haven't already.
Everything in this section is added in this file.

### Stripe
```
stripe:
  public_key: "get this from stripe testing sandbox"
  secret_key: "get this from stripe testing sandbox"
  payments_webhook_secret: "get this from running stripe cli"
```

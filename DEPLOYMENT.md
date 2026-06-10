# Deployment Guide
Assumes server runs on Ubuntu.

## PostgreSQL
***WIP***
1. First install PostgreSQL if haven't:
- `sudo` or run some script
2. If haven't, generate password using `openssl` and place it in env variable `BEATSTORE_DATABASE_PASSWORD`
- e.g. `openssl rand -hex 32`

## OAuth2
Check that OAuth2 origin and callbacks in production environment exists for:
- [Google](https://console.cloud.google.com/auth/clients)
  - Authorized JavaScript origins: `http://prodethan.com`
  - Authorized redirect URIs: `http://prodethan.com/auth/google_oauth2/callback`

# Deployment Guide
Assumes server runs on Ubuntu.

## SSH Guide
1. Generate SSH key on local machine, if server doesn't recognize your local machine
- Guide: https://community.hetzner.com/tutorials/howto-ssh-key
2. Add generated public SSH key to server
- i.e. `id_<type>.pub`
3. SSH into server
- IPv4 `ssh root@<0.0.0.0>`
- IPv6 `ssh -6 root@[IPv6]`

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

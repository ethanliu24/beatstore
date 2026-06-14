# Deployment Guide
Assumes server runs on Ubuntu.

## Deploy
```
$ ./bin/deploy
```

## SSH Guide
1. Generate SSH key on local machine, if server doesn't recognize your local machine
- Guide: https://community.hetzner.com/tutorials/howto-ssh-key
2. Add generated public SSH key to server
- i.e. `id_<type>.pub`
3. SSH into server
- IPv4 `ssh root@<0.0.0.0>`
- IPv6 `ssh -6 root@[IPv6]`

## PostgreSQL

### Set up
1. First install PostgreSQL if haven't:
2. If haven't, generate password using `openssl` and place it in credentials file
- e.g. `openssl rand -hex 32`

### Notes
- Comprehensive guide: https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart
- Prod uses version 18.4 as of Jun 13, 2026. Check with `psql --version`
- PostgreSQL should not be exposed to the public and should only listen on localhost. Installation should default to listening locally only. If want to expose, follow the guide for details on how to do it securly.
- Create user `beatstore` with `CREATE DB` rights
- Test role is set up correctly:
  - In `psql`, `\du` to see all users
  - Check password (it will prompt to enter): `psql -U beatstore -d postgres -h localhost -W`

## Docker

### Docker Hub
- Install Docker CLI if haven't
- Locate beatstore image in DockerHub
- Generate new Personal Access Tokens as `KAMAL_REGISTRY_PASSWORD` in env file

### Docker
- Use `Docker VMM` VM in Docker Desktop setting to not break tailwind

## OAuth2
Check that OAuth2 origin and callbacks in production environment exists for:
- [Google](https://console.cloud.google.com/auth/clients)
  - Authorized JavaScript origins: `http://prodethan.com`
  - Authorized redirect URIs: `http://prodethan.com/auth/google_oauth2/callback`

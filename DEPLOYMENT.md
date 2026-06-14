# Deployment Guide
Assumes server runs on Ubuntu.

## Deploy
```
# if rebooted server / or turning power on again, ssh in to server and restart pg: sudo systemctl restart postgresql
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
3. Since deploying with Kamal, set listen port to listen for Docker's intenral network:
- Check IP address (should be `172.17.0.1`): `ip addr show docker0`
- Append it the address to `listen_addresses`: `sudo nano /etc/postgresql/18/main/postgresql.conf`
- Append this at the end of file: `host    all             all             172.16.0.0/12           scram-sha-256`
- Restart PostgreSQL: `sudo systemctl restart postgresql`
4. Create neccessary databases
- `beatstore_production`
- `beatstore_production_queue`
- `beatstore_production_cache` (Not used atm)
- `beatstore_production_cable` (Not used atm)

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
  - Authorized JavaScript origins: `https://prodethan.com`
  - Authorized redirect URIs: `https://prodethan.com/auth/google_oauth2/callback`
- Rotating secrets:
  - Add new secret and copy the value
  - Put it in credentials file
  - Disable and delete the old secret if neccessary

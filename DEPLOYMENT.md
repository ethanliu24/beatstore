# Deployment Guide

## OAuth2
Check that OAuth2 origin and callbacks in production environment exists for:
- [Google](https://console.cloud.google.com/auth/clients)
  - Authorized JavaScript origins: `http://prodethan.com`
  - Authorized redirect URIs: `http://prodethan.com/auth/google_oauth2/callback`

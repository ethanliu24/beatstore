# Authentication

## Overview

The Beatstore platform uses JWT (JSON Web Token) based authentication. All authenticated endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Authentication Routes

### Sign In
`POST /api/sign_in`

Authenticate a user and receive a JWT token.

#### Request Body
```json
{
  "email": "string",
  "password": "string",
  "remember_me": "boolean"
}
```

#### Response
```json
{
  "data": {
    "token": "jwt_token_string",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "username": "producer123"
    }
  }
}
```

### Sign Out
`DELETE /api/sign_out`

Invalidate the current user's token.

#### Response
Status: 204 No Content

### Sign Up
`POST /sign_up`

Create a new user account.

#### Request Body
```json
{
  "email": "string",
  "username": "string",
  "password": "string",
  "password_confirmation": "string"
}
```

#### Response
```json
{
  "data": {
    "token": "jwt_token_string",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "username": "producer123"
    }
  }
}
```

# For future (not carefully designed yet)

## Password Management

### Request Password Reset
`POST /api/password/reset`

Request a password reset email.

#### Request Body
```json
{
  "email": "string"
}
```

#### Response
Status: 200 OK
```json
{
  "message": "Password reset instructions sent if email exists"
}
```

### Reset Password
`PUT /api/password/reset`

Reset password using a reset token.

#### Request Body
```json
{
  "user_id": "int",
  "token": "string",
  "password": "string",
  "password_confirmation": "string"
}
```

#### Response
```json
{
  "data": {
    "token": "new_jwt_token_string",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "username": "producer123"
    }
  }
}
```

## Token Management

### Refresh Token
`POST /token/refresh`

Get a new JWT token before the current one expires.

#### Request
Requires current valid JWT token in Authorization header.

#### Response
```json
{
  "data": {
    "token": "new_jwt_token_string"
  }
}
```

## Error Responses

### Invalid Credentials
```json
{
  "errors": [
    {
      "code": "invalid_credentials",
      "message": "Invalid email or password"
    }
  ]
}
```

### Invalid Token
```json
{
  "errors": [
    {
      "code": "invalid_token",
      "message": "Token is invalid or expired"
    }
  ]
}
```

### Validation Errors
```json
{
  "errors": [
    {
      "code": "validation_error",
      "message": "Validation failed",
      "details": {
        "password": ["must be at least 8 characters"],
        "email": ["is already taken"]
      }
    }
  ]
}
```

## Security Notes

- Passwords must be at least 8 characters
- Passwords are hashed using bcrypt
- JWT tokens expire after 24 hours
- Remember me extends token life to 30 days
- Failed login attempts are rate limited
- Password reset tokens expire after 1 hour
- Sessions are invalidated on password change
- 2FA will be supported in future updates
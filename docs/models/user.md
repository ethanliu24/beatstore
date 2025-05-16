# User Model

Represents a user in the system, can be either a customer or admin.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | integer | Unique identifier for the user | Auto-increment | Primary key |
| email | string | User's email address | - | Must be unique |
| password | string | Encrypted password | - | Should be hashed before storage |
| password_confirmation | string | Password confirmation for validation | - | Virtual attribute, not stored |
| username | string | User's display name | - | Must be unique |
| role | Role | User's role in the system | customer | See [Role enum](#role-enum) |
| profile_pic | string | URL to user's profile picture | link-to-default-pfp | |
| created_at | timestamp | When the user was created | Current time | |
| updated_at | timestamp | When the user was last updated | Current time | |
| stripe_customer_id | string | Stripe Customer ID | null | Optional, for Stripe integration |

## Role Enum

Defines the possible roles a user can have in the system.

| Value | Description |
|-------|-------------|
| customer | Regular user who can purchase and download tracks |
| admin | Administrator with full system access |
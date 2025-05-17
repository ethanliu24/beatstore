# User Model

Represents a user in the system, can be either a customer or admin.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | integer | Unique identifier for the user | Auto-increment | Primary key |
| email | string | User's email address | - | Must be unique |
| encrypted_password | string | Hashed password | - | Required by Devise |
| username | string | User's display name | - | Must be unique |
| role | Role | User's role in the system | customer | See [Role enum](#role-enum) |
| profile_pic | string | URL to user's profile picture | link-to-default-pfp | |
| created_at | timestamp | When the user was created | Current time | |
| updated_at | timestamp | When the user was last updated | Current time | |
| reset_password_token | string | Token used to reset password | null | Unique, generated on password reset |
| reset_password_sent_at | datetime | Time when reset password token was sent | null | Used for expiration logic |
| remember_created_at | datetime | Timestamp for "remember me" login feature | null | Devise's rememberable module |
| confirmation_token | string | Token used for email confirmation | null | Unique, used with confirmable module |
| confirmed_at | datetime | Timestamp of when email was confirmed | null | Null until email is confirmed |
| confirmation_sent_at | datetime  | Timestamp of when confirmation was sent | null | Used to throttle confirmation sending |
| unconfirmed_email | string | New email pending confirmation | null | Used when updating email |
| stripe_customer_id | string | Stripe Customer ID | null | Optional, for Stripe integration |

## Role Enum

Defines the possible roles a user can have in the system.

| Value | Description |
|-------|-------------|
| customer: 0 | Regular user who can purchase and download tracks |
| admin: 1 | Administrator with full system access |
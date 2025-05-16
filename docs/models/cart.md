# Cart Model

## CartItem

Represents items in a user's shopping cart.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| user_id | integer | ID of the user | - | Foreign key to User |
| track_id | integer | ID of the track | - | Foreign key to Track |

## Notes

- Simple join table between User and Track
- Used for temporary storage before purchase
- Items are removed after successful purchase
- No timestamps needed as cart items are temporary
- One user can have multiple tracks in cart
- Same track can be in multiple users' carts
# Order Models

## Order

Represents a purchase order in the system.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | uuid | Unique identifier for the order | Generated UUID | Primary key |
| user_id | integer | ID of user who placed the order | null | Optional for anonymous checkout |
| user_email | string | Email address for order delivery | - | Required |
| total_amount_cents | integer | Total order amount in cents | - | Required |
| currency | string | Currency of the order | "cad" | ISO currency code |
| status | PaymentStatus | Current status of the order | pending | See [PaymentStatus enum](#payment-status-enum) |
| purchased_at | string | When the order was completed | null | Set when payment succeeds |
| created_at | timestamp | When the order was created | Current time | |
| updated_at | timestamp | When the order was last updated | Current time | |

## OrderItem

Represents an individual item within an order.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| order_id | integer | ID of the parent order | - | Foreign key to Order |
| track_id | integer | ID of the purchased track | - | Foreign key to Track |
| license | integer | ID of the license type | - | Foreign key to License |
| price_cents | integer | Price of item in cents | - | Required |
| created_at | timestamp | When the item was created | Current time | |
| updated_at | timestamp | When the item was last updated | Current time | |

## Payment Status Enum

Possible states of an order's payment.

| Value | Description |
|-------|-------------|
| pending | Payment not yet processed |
| paid | Payment successful |
| failed | Payment failed |
| refunded | Payment was refunded |
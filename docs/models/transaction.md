# Transaction Model

Represents payment transactions in the system, primarily integrated with Stripe.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| order | integer | ID of the associated order | - | Foreign key to Order |
| stripe_payment_intent_id | string | Stripe Payment Intent ID | - | For payment tracking |
| stripe_charge_id | string | Stripe Charge ID | - | For payment tracking |
| amount_cents | integer | Transaction amount in cents | - | Required |
| currency | string | Transaction currency | - | ISO currency code |
| status | TransactionStatus | Current status of transaction | - | See [TransactionStatus enum](#transaction-status-enum) |
| payment_method_type | PaymentMethod | Method used for payment | - | See [PaymentMethod enum](#payment-method-enum) |
| failure_reason | string | Reason for failed transaction | null | For debugging |
| receipt_url | string | URL to Stripe receipt | null | From Stripe |
| processed_at | datetime | When transaction was processed | - | |
| created_at | timestamp | When record was created | Current time | |
| updated_at | timestamp | When record was last updated | Current time | |

## Transaction Status Enum

Possible states of a transaction.

| Value | Description |
|-------|-------------|
| succeeded | Transaction completed successfully |
| failed | Transaction failed |
| requires_action | Additional action needed (e.g., 3D Secure) |

## Payment Method Enum

Supported payment methods.

| Value | Description |
|-------|-------------|
| card | Credit/Debit card payment |
| paypal | PayPal payment |

## Notes

- Closely integrated with Stripe payment processing
- Maintains complete payment audit trail
- Stores external IDs for payment tracking
- Includes debugging information for failed payments
# Orders & Payments API Endpoints (TBU)

## List Orders
`GET /api/orders`

Get list of orders for the authenticated user.

### Query Parameters
- `page` (integer, optional) - Page number, default: 1
- `per_page` (integer, optional) - Items per page, default: 20
- `status` (string, optional) - Filter by status: pending, paid, failed

### Response
```json
{
  "data": [
    {
      "id": 1,
      "type": "order",
      "attributes": {
        "total_amount_cents": 4999,
        "currency": "cad",
        "status": "paid",
        "created_at": "2024-03-20T12:00:00Z",
        "completed_at": "2024-03-20T12:05:00Z"
      },
      "relationships": {
        "order_items": {
          "data": [
            { "id": 1, "type": "order_item" }
          ]
        }
      }
    }
  ],
  "meta": {
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_count": 48,
      "per_page": 10
    }
  }
}
```

## Get Order Details
`GET /api/orders/:id`

Get detailed information about a specific order. Requires authentication and ownership.

### Response
```json
{
  "data": {
    "id": 1,
    "type": "order",
    "attributes": {
      "total_amount_cents": 4999,
      "currency": "cad",
      "status": "paid",
      "created_at": "2024-03-20T12:00:00Z",
      "completed_at": "2024-03-20T12:05:00Z",
      "payment_method": "stripe",
      "email": "customer@example.com"
    },
    "relationships": {
      "order_items": {
        "data": [
          {
            "id": 1,
            "type": "order_item",
            "attributes": {
              "price_cents": 4999
            },
            "relationships": {
              "track": { "data": { "id": 1, "type": "track" } },
              "license": { "data": { "id": 1, "type": "license" } }
            }
          }
        ]
      }
    }
  }
}
```

## Create Order
`POST /api/orders`

Create a new order from cart items. Initiates checkout process.

### Request Body
```json
{
  "email": "string (required for anonymous checkout)",
  "payment_method": "PaymentMethod",
  "currency": "string (default: cad)"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "order",
    "attributes": {
      "total_amount_cents": 4999,
      "currency": "cad",
      "status": "pending",
      "checkout_url": "https://checkout.stripe.com/...",
      "created_at": "2024-03-20T12:00:00Z"
    }
  }
}
```

## Validate Cart
`POST /api/orders/validate`

Validate cart items before checkout. Checks item availability and pricing.

### Request Body
```json
{
  "cart_items": [
    {
      "track_id": "integer",
      "license_id": "integer"
    }
  ]
}
```

### Response
```json
{
  "data": {
    "valid": true,
    "total_amount_cents": 4999,
    "items": [
      {
        "track_id": 1,
        "license_id": 1,
        "price_cents": 4999,
        "available": true
      }
    ]
  }
}
```

### Error Response
```json
{
  "errors": [
    {
      "code": "invalid_cart",
      "message": "Some items are no longer available",
      "details": {
        "unavailable_items": [
          {
            "track_id": 2,
            "reason": "track_removed"
          }
        ]
      }
    }
  ]
}
```

## Notes
- Orders can be created by both authenticated and anonymous users
- Anonymous orders require an email address
- Payment is processed through Stripe
- Successful orders trigger download link emails
- Cart validation should be performed before checkout
- Orders expire after 24 hours if not completed
- Failed orders can be retried within 48 hours
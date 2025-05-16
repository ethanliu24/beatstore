# User API Endpoints (TBU)

## Get User Profile
`GET /api/users/:id`

Get public user profile information.

### Response
```json
{
  "data": {
    "id": 1,
    "type": "user",
    "attributes": {
      "username": "producer123",
      "profile_pic": "url/to/pic.jpg",
      "created_at": "2024-03-20T12:00:00Z"
    },
    "relationships": {
      "hearted_tracks": {
        "data": [
          { "id": 1, "type": "track" }
        ]
      }
    }
  }
}
```

## Update User
`PUT /api/users/:id`

Update user information. Requires authentication and ownership.

### Request Body
```json
{
  "email": "string (optional)",
  "username": "string (optional)",
  "profile_pic": "file (optional)",
  "current_password": "string (required for email/password update)",
  "password": "string (optional)",
  "password_confirmation": "string (required if password provided)"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "user",
    "attributes": {
      // Same as user profile response
    }
  }
}
```

## Cart Management

### List Cart Items
`GET /api/users/:id/cart`

Get items in user's cart. Requires authentication and ownership.

### Response
```json
{
  "data": [
    {
      "id": 1,
      "type": "cart_item",
      "attributes": {
        "added_at": "2024-03-20T12:00:00Z"
      },
      "relationships": {
        "track": {
          "data": { "id": 1, "type": "track" }
        },
        "license": {
          "data": { "id": 1, "type": "license" }
        }
      }
    }
  ],
  "meta": {
    "total_items": 2,
    "total_amount_cents": 4999
  }
}
```

### Add to Cart
`POST /api/users/:id/cart`

Add a track to cart. Requires authentication and ownership.

### Request Body
```json
{
  "track_id": "integer",
  "license_id": "integer"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "cart_item",
    "attributes": {
      // Same as cart item in list response
    }
  }
}
```

### Remove from Cart
`DELETE /api/users/:id/cart/:track_id`

Remove a track from cart. Requires authentication and ownership.

### Response
Status: 204 No Content

## Favorites Management

### List Favorites
`GET /api/users/:id/favorites`

Get user's favorited tracks.

### Query Parameters
- `page` (integer, optional) - Page number, default: 1
- `per_page` (integer, optional) - Items per page, default: 20

### Response
```json
{
  "data": [
    {
      "id": 1,
      "type": "track",
      "attributes": {
        // Track attributes
      },
      "meta": {
        "hearted_at": "2024-03-20T12:00:00Z"
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

## Purchase History

### List Purchases
`GET /api/users/:id/purchases`

Get user's purchase history. Requires authentication and ownership.

### Query Parameters
- `page` (integer, optional) - Page number, default: 1
- `per_page` (integer, optional) - Items per page, default: 20

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
        "purchased_at": "2024-03-20T12:00:00Z"
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

## Notes
- Profile pictures are automatically resized
- Email changes require current password verification
- Password changes trigger session logout on other devices
- Cart items expire after 24 hours
- Purchase history includes both successful and failed orders
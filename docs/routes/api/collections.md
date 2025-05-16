# Collection API Endpoints (TBU)

## List Collections
`GET /api/collections`

List all public collections.

### Query Parameters
- `page` (integer, optional) - Page number, default: 1
- `per_page` (integer, optional) - Items per page, default: 20

### Response
```json
{
  "data": [
    {
      "id": 1,
      "type": "collection",
      "attributes": {
        "title": "Summer Pack 2024",
        "description": "Hot summer beats collection",
        "is_public": true,
        "track_count": 5,
        "created_at": "2024-03-20T12:00:00Z"
      },
      "relationships": {
        "tracks": {
          "data": [
            { "id": 1, "type": "track" },
            { "id": 2, "type": "track" }
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

## Create Collection
`POST /api/collections`

Create a new collection. Requires admin role.

### Request Body
```json
{
  "title": "string",
  "description": "string",
  "is_public": "boolean"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "collection",
    "attributes": {
      // Same as collection list response
    }
  }
}
```

## Update Collection
`PUT /api/collections/:id`

Update an existing collection. Requires admin role.

### Request Body
Same as POST but all fields optional

### Response
Same as POST response

## Delete Collection
`DELETE /api/collections/:id`

Delete a collection. Requires admin role.

### Response
Status: 204 No Content

## Collection Track Management

### Add Track
`POST /api/collections/:id/tracks`

Add a track to the collection. Requires admin role.

### Request Body
```json
{
  "track_id": "integer"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "collection",
    "attributes": {
      // Collection data with updated track list
    }
  }
}
```

### Remove Track
`DELETE /api/collections/:id/tracks/:track_id`

Remove a track from the collection. Requires admin role.

### Response
Status: 204 No Content
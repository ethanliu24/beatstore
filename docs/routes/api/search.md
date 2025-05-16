# Search & Filter API Endpoints (TBU)

## Global Search
`GET /api/search`

Search across tracks, collections, and users.

### Query Parameters
- `q` (string, required) - Search query
- `type` (string, optional) - Filter by type: tracks, collections, users
- `page` (integer, optional) - Page number, default: 1
- `per_page` (integer, optional) - Items per page, default: 20

### Response
```json
{
  "data": {
    "tracks": [
      {
        "id": 1,
        "type": "track",
        "attributes": {
          "title": "Summer Beat",
          "description": "Upbeat summer vibes",
          "bpm": 128,
          "key": "C Major",
          "genre": "Pop"
        }
      }
    ],
    "collections": [
      {
        "id": 1,
        "type": "collection",
        "attributes": {
          "title": "Summer Collection",
          "description": "Best summer beats"
        }
      }
    ],
    "users": [
      {
        "id": 1,
        "type": "user",
        "attributes": {
          "username": "producer123"
        }
      }
    ]
  },
  "meta": {
    "total_results": 45,
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "per_page": 20
    }
  }
}
```

## Track Filters
`GET /api/tracks`

Get tracks with advanced filtering options.

### Query Parameters
- `genre` (string, optional) - Filter by genre
- `bpm_min` (integer, optional) - Minimum BPM
- `bpm_max` (integer, optional) - Maximum BPM
- `key` (string, optional) - Musical key
- `price_min_cents` (integer, optional) - Minimum price in cents
- `price_max_cents` (integer, optional) - Maximum price in cents
- `sort` (string, optional) - Sort by: newest, popular, price_asc, price_desc
- `tags` (array, optional) - Filter by tags
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
        "title": "Summer Beat",
        "description": "Upbeat summer vibes",
        "bpm": 128,
        "key": "C Major",
        "genre": "Pop",
        "price_cents": 2999,
        "created_at": "2024-03-20T12:00:00Z",
        "play_count": 1500,
        "download_count": 50,
        "tags": ["summer", "upbeat", "pop"]
      },
      "relationships": {
        "user": {
          "data": { "id": 1, "type": "user" }
        },
        "licenses": {
          "data": [
            { "id": 1, "type": "license" }
          ]
        }
      }
    }
  ],
  "meta": {
    "filters": {
      "applied": {
        "genre": "Pop",
        "bpm_min": 120,
        "bpm_max": 130
      },
      "available": {
        "genres": ["Pop", "Hip Hop", "R&B"],
        "keys": ["C Major", "A Minor"],
        "tags": ["summer", "upbeat", "dark", "chill"]
      }
    },
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_count": 48,
      "per_page": 10
    }
  }
}
```

## Genre Tracks
`GET /api/genres/:genre/tracks`

Get tracks for a specific genre.

### Query Parameters
Same as Track Filters endpoint, except `genre` parameter.

### Response
Same as Track Filters endpoint.

## Notes
- Search is performed on titles, descriptions, and tags
- Search supports partial matching and relevance scoring
- Genre names are standardized and case-insensitive
- BPM ranges are inclusive
- Price filters apply to the lowest license price
- Sort options affect search relevance
- Available filters are dynamically generated
- Tag search supports multiple tags (AND operation)
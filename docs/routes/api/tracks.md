# Track API Endpoints

## List Tracks (TBU)
`GET /api/tracks`

List all public tracks with filtering options.

### Query Parameters
- `q` (string, optional) - Search term
- `genre` (string, optional) - Filter by genre
- `sort` (string, optional) - Sort by: latest, popular, hearts
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
        "description": "Hot summer vibes",
        "key": "C minor",
        "bpm": 140,
        "genre": "Hip Hop",
        "hearts": 150,
        "plays": 1200,
        "cover_photo": "url/to/photo.jpg",
        "created_at": "2024-03-20T12:00:00Z"
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

## Create Track
`POST /api/tracks`

Create a new track. Requires admin role.

### Request Body
```json
{
  "title": "string",
  "description": "string",
  "key": "string",
  "bpm": "integer",
  "genre": "Genre",
  "is_public": "boolean",
  "collection_id": "integer (optional)",
  "tagged_mp3": "file",
  "untagged_mp3": "file",
  "untagged_wav": "file",
  "track_stems": "file (optional)",
  "project": "file (optional)",
  "cover_photo": "file"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "track",
    "attributes": {
      // Same as track list response
    }
  }
}
```

## Update Track
`PUT /api/tracks/:id`

Update an existing track. Requires admin role.

### Request Body
Same as POST but all fields optional

### Response
Same as POST response

## Delete Track
`DELETE /api/tracks/:id`

Delete a track. Requires admin role.

### Response
Status: 204 No Content

## Track Actions

### Increment Play Count
`POST /api/tracks/:id/play`

Record a play for the track.

### Response
```json
{
  "data": {
    "plays": 1201
  }
}
```

### Heart/Unheart Track
`POST /api/tracks/:id/heart`

Toggle heart status for current user.

### Response
```json
{
  "data": {
    "hearts": 151,
    "hearted": true
  }
}
```

### Download Track
`GET /api/tracks/:id/free-download` - No license required.

`GET /api/tracks/:id/download`

Download track files. Requires valid license purchase.

### Query Parameters
- `type` (string, required) - One of: tagged_mp3, untagged_mp3, untagged_wav, stems, project

### Request Body
```json
{
  "order_id": "uuid",
  "license_id": "integer"
}
```

### Response
File download response with appropriate Content-Type header

### Error Responses
```json
{
  "errors": [
    {
      "code": "invalid_license",
      "message": "The provided license does not grant access to this file type"
    }
  ]
}
```
OR
```json
{
  "errors": [
    {
      "code": "invalid_order",
      "message": "No valid purchase found for this track"
    }
  ]
}
```

### Notes
- Tagged MP3s are freely available without purchase
- Other file types require valid order and appropriate license level
- Stems and project files only available with higher tier licenses
- Download links are time-limited for security
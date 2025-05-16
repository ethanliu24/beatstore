# Comments API Endpoints (TBU)

## List Comments
`GET /api/tracks/:track_id/comments`

Get comments for a specific track.

### Query Parameters
- `page` (integer, optional) - Page number, default: 1
- `per_page` (integer, optional) - Items per page, default: 20

### Response
```json
{
  "data": [
    {
      "id": 1,
      "type": "comment",
      "attributes": {
        "body": "Great beat!",
        "created_at": "2024-03-20T12:00:00Z",
        "updated_at": "2024-03-20T12:00:00Z",
        "likes_count": 5,
        "dislikes_count": 0
      },
      "relationships": {
        "user": {
          "data": { "id": 1, "type": "user" }
        },
        "replies": {
          "data": [
            { "id": 2, "type": "comment" }
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

## Create Comment
`POST /api/tracks/:track_id/comments`

Create a new comment on a track. Requires authentication.

### Request Body
```json
{
  "body": "string",
  "parent_comment_id": "integer (optional, for replies)"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "comment",
    "attributes": {
      // Same as comment in list response
    }
  }
}
```

## Update Comment
`PUT /api/comments/:id`

Update an existing comment. Requires authentication and ownership.

### Request Body
```json
{
  "body": "string"
}
```

### Response
```json
{
  "data": {
    "id": 1,
    "type": "comment",
    "attributes": {
      // Same as comment in list response
    }
  }
}
```

## Delete Comment
`DELETE /api/comments/:id`

Delete a comment. Requires authentication and ownership.

### Response
Status: 204 No Content

## Like Comment
`POST /api/comments/:id/like`

Like a comment. Requires authentication.

### Response
```json
{
  "data": {
    "id": 1,
    "type": "comment",
    "attributes": {
      "likes_count": 6,
      "dislikes_count": 0
    }
  }
}
```

## Dislike Comment
`POST /api/comments/:id/dislike`

Dislike a comment. Requires authentication.

### Response
```json
{
  "data": {
    "id": 1,
    "type": "comment",
    "attributes": {
      "likes_count": 5,
      "dislikes_count": 1
    }
  }
}
```

## Reply to Comment
`POST /api/comments/:id/reply`

Create a reply to an existing comment. Requires authentication.

### Request Body
```json
{
  "body": "string"
}
```

### Response
```json
{
  "data": {
    "id": 2,
    "type": "comment",
    "attributes": {
      // Same as comment in list response
    },
    "relationships": {
      "parent_comment": {
        "data": { "id": 1, "type": "comment" }
      }
    }
  }
}
```

## Notes
- Comments support one level of nesting (replies)
- Users can both like and dislike a comment
- Deleting a parent comment also deletes all replies
- Comment mentions (@username) trigger notifications
- HTML tags are stripped from comment bodies
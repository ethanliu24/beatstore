# Collection Model

Represents a grouping of related tracks (e.g., albums, beat packs).

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | integer | Unique identifier for the collection | Auto-increment | Primary key |
| title | string | Name of the collection | - | Required |
| description | string | Description of the collection | - | Optional |
| is_public | boolean | Whether collection is visible to public | false | |
| created_at | timestamp | When the collection was created | Current time | |
| updated_at | timestamp | When the collection was last updated | Current time | |

## Notes

- Collections can be used to group related tracks together
- Tracks can reference a collection through their `collection_id` field
- Private collections can be used for organizing unreleased tracks
- Collections can be used for special promotions or releases
# User Interaction Models

## HeartedTrack

Represents when a user hearts/favorites a track.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| user_id | integer | ID of the user | - | Foreign key to User |
| track_id | integer | ID of the track | - | Foreign key to Track |
| hearted_at | timestamp | When the track was hearted | Current time | |

## Comment

Represents user comments on tracks.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | integer | Unique identifier for the comment | Auto-increment | Primary key |
| user_id | integer | ID of the commenting user | - | Foreign key to User |
| body | string | Content of the comment | - | Required |
| parent_comment_id | integer | ID of parent comment | null | For nested replies |
| likes_count | integer | Number of likes | 0 | |
| dislikes_count | integer | Number of dislikes | 0 | |
| created_at | timestamp | When comment was created | Current time | |
| updated_at | timestamp | When comment was last updated | Current time | |

## CommentReaction

Represents user reactions (likes/dislikes) on comments.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| comment_id | integer | ID of the comment | - | Foreign key to Comment |
| user_id | integer | ID of the reacting user | - | Foreign key to User |
| liked | boolean | Whether reaction is like or dislike | - | true=like, false=dislike |
| reacted_at | timestamp | When reaction was made | Current time | |

## Notes

- HeartedTrack is used for wishlist/favorites functionality
- Comments support nested replies through parent_comment_id
- Comment reactions are used to show community feedback
- These models help track user engagement with content
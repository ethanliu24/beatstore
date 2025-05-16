# Track Model

Represents a music track/beat in the system.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | integer | Unique identifier for the track | Auto-increment | Primary key |
| title | string | Name of the track | - | Required |
| description | string | Description of the track | - | Optional |
| key | string | Musical key of the track | - | e.g. "C minor", "G major" |
| bpm | integer | Beats per minute | - | Required |
| hearts | integer | Number of times track was hearted | 0 | |
| plays | integer | Number of times track was played | 0 | |
| is_public | boolean | Whether track is visible to public | false | |
| genre | Genre | Genre of the track | - | See [Genre enum](#genre-enum) |
| collection_id | integer | ID of collection this track belongs to | null | Optional |
| tagged_mp3 | string | URL to tagged MP3 version | "" | With producer tag |
| untagged_mp3 | string | URL to untagged MP3 version | "" | Without producer tag |
| untagged_wav | string | URL to untagged WAV version | "" | High quality version |
| track_stems | string | URL to track stems | "" | Individual track components |
| project | string | URL to project files | "" | Original project files |
| cover_photo | string | URL to track artwork | link-to-default-cover | |
| created_at | timestamp | When the track was created | Current time | |
| updated_at | timestamp | When the track was last updated | Current time | |

## Genre Enum

Available music genres in the system.

| Value | Description |
|-------|-------------|
| Hip Hop | Hip-hop/rap beats |
| Plugnb | Plug-style beats |
| New Jazz | Modern jazz fusion |
| Trap | Trap-style beats |
| RnB | R&B/Soul beats |
| Underground Rap | Underground hip-hop style |
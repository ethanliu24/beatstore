# Licenses API Endpoints (TBU)

## List Licenses
`GET /api/licenses`

Get list of available license types.

### Response
```json
{
  "data": [
    {
      "id": 1,
      "type": "license",
      "attributes": {
        "name": "Basic License",
        "description": "For non-profit use only",
        "price_cents": 2999,
        "features": [
          "MP3 file",
          "Non-exclusive rights",
          "Up to 10,000 streams"
        ],
        "terms": {
          "max_streams": 10000,
          "max_videos": 1,
          "max_radio_stations": 0,
          "allow_commercial": false,
          "allow_music_videos": true,
          "allow_performance": false
        }
      }
    }
  ]
}
```

## Get License Details
`GET /api/licenses/:id`

Get detailed information about a specific license type.

### Response
```json
{
  "data": {
    "id": 1,
    "type": "license",
    "attributes": {
      "name": "Basic License",
      "description": "For non-profit use only",
      "price_cents": 2999,
      "features": [
        "MP3 file",
        "Non-exclusive rights",
        "Up to 10,000 streams"
      ],
      "terms": {
        "max_streams": 10000,
        "max_videos": 1,
        "max_radio_stations": 0,
        "allow_commercial": false,
        "allow_music_videos": true,
        "allow_performance": false
      },
      "included_files": [
        "tagged_mp3",
        "untagged_mp3"
      ],
      "contract_template": "basic_license_v1",
      "created_at": "2024-03-20T12:00:00Z",
      "updated_at": "2024-03-20T12:00:00Z"
    }
  }
}
```

## License Types

The platform offers several standard license types:

1. Basic License
   - Non-commercial use
   - MP3 files only
   - Limited streams/videos
   - No performance rights

2. Premium License
   - Commercial use
   - MP3 + WAV files
   - Higher stream limits
   - Music video rights
   - Performance rights

3. Exclusive License
   - Full ownership transfer
   - All file formats (MP3, WAV, Stems)
   - Unlimited usage
   - Removal from platform after purchase

4. Custom License
   - Negotiable terms
   - Contact required
   - Custom pricing
   - Flexible usage rights

## Notes
- License terms are enforced through the platform
- License upgrades are available (e.g., Basic to Premium)
- Each track can have different available licenses
- License prices may vary by track
- Licenses are non-transferable
- Some licenses may require additional verification
- Contract generation is automatic on purchase
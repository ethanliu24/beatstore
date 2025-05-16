# License Model

Represents different types of licenses available for tracks. The system maintains a fixed set of license types.

| Field | Type | Description | Default | Notes |
|-------|------|-------------|---------|-------|
| id | integer | Unique identifier for the license | Auto-increment | Primary key |
| type | LicenseType | Type of the license | - | See [LicenseType enum](#license-type-enum) |
| description | string | Detailed description of license terms | - | Required |
| copyright_terms | string | Legal copyright terms | - | Required |
| price_cents | integer | Price of license in cents | - | Required |
| created_at | timestamp | When the license was created | Current time | |
| updated_at | timestamp | When the license was last updated | Current time | |

## License Type Enum

Available types of licenses that can be purchased.

| Value | Description |
|-------|-------------|
| MP3 Lease | Basic lease with MP3 delivery |
| WAV Lease | Standard lease with WAV delivery |
| Tracked Out Lease | Premium lease with individual track stems |
| Unlimited Lease | Unlimited usage lease |
| Exclusive Lease | Exclusive rights to the track |

## Notes

- The system maintains only 5 license types
- All `license` fields in other models reference this table
- Each license type has different usage rights and deliverables
- Price typically increases with more rights/deliverables
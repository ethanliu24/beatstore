# Page Routes (TBU)

## Authentication Pages

### Sign In
`GET /sign_in`

The sign in page where users can authenticate with their account.

### Sign Up
`GET /sign_up`

The registration page for new users to create an account.

## Public Pages

### Homepage
`GET /`

The main landing page showing:
- Featured tracks
- Latest releases
- Popular tracks
- Featured collections

### Track Listings
`GET /tracks`

Browse all public tracks with:
- Advanced filtering options
- Search functionality
- Genre categories
- Sorting options

### Single Track
`GET /tracks/:id`

Detailed view of a single track showing:
- Track information and metadata
- License options
- Comments section
- Related tracks
- Producer information

### Collections
`GET /collections`

Browse all public collections with:
- Collection categories
- Featured collections
- Producer collections
- Genre-based collections

### Single Collection
`GET /collections/:id`

Detailed view of a collection showing:
- Collection information
- Track listing
- Producer information
- Purchase options

## User Account & Profile Pages

### User Profile
`GET /users/:id`

Public profile page showing:
- User information
- Published tracks
- Collections
- Activity

`GET /users/:id/edit`

Page for editing account settings:
- Profile information
- Email address
- Password
- Profile picture

### User Favorites
`GET /users/:id/favorites`

Page showing user's favorited tracks:
- Favorited tracks listing
- Filter options
- Quick play options

### Purchase History
`GET /users/:id/purchases`

User's purchase history showing:
- Past orders
- Download links
- License information
- Order details

### Shopping Cart
`GET /users/:id/cart`

User's shopping cart showing:
- Cart items
- License selection
- Total calculation
- Checkout button

## Shopping Pages

### Checkout
`GET /checkout`

Secure checkout page with:
- Order summary
- Payment method selection
- Email collection (for anonymous users)
- Terms acceptance

### Checkout Success
`GET /checkout/success`

Order confirmation page showing:
- Order details
- Download instructions
- Email confirmation
- Next steps

### Checkout Cancel
`GET /checkout/cancel`

Page shown when checkout is cancelled:
- Return to cart option
- Continue shopping
- Save for later

## Admin Pages

### Admin Dashboard
`GET /admin`

Main admin control panel showing:
- Overview statistics
- Recent activity
- Quick actions
- System status

### Track Management
`GET /admin/tracks`

Admin track management showing:
- Track listing
- Bulk actions
- Filter options
- Analytics

### Collection Management
`GET /admin/collections`

Admin collection management showing:
- Collection listing
- Creation/editing tools
- Track organization
- Featured settings

### License Management
`GET /admin/licenses`

Admin license management showing:
- License types
- Pricing configuration
- Terms editing
- Contract templates

### Order Management
`GET /admin/orders`

Admin order management showing:
- Order listing
- Status updates
- Customer information
- Payment details

### Transaction History
`GET /admin/transactions`

Admin transaction view showing:
- Transaction listing
- Payment reconciliation
- Refund management
- Financial reports

## Notes
- All admin pages require admin authentication
- Shopping pages maintain cart state
- Checkout pages are SSL encrypted
- Profile pages respect privacy settings
- Admin pages include audit logging
- Success/error messages use flash notifications
- All pages are responsive
- Navigation includes breadcrumbs
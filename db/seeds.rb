# === Users ===
User.create(
  display_name: "Admin",
  username: "admin",
  email: "admin@email.com",
  password: "12345678",
  role: :admin,
  confirmed_at: Time.now
)

customer = User.create(
  display_name: "Customer",
  username: "customer",
  email: "customer@email.com",
  password: "12345678",
  role: :customer,
  confirmed_at: Time.now
)

# === Tracks ===
track_1 = Track.create(
  title: "Pinis",
  bpm: 69,
  key: "A MINOR",
  is_public: true,
  genre: Track::GENRES[0]
)

Track.create(
  title: "Nair Type Beat",
  bpm: 130,
  key: "C# MAJOR",
  is_public: false,
  genre: Track::GENRES[-1]
)


# === Comments ===
Comment.create(
  content: "This is shit",
  entity: track_1,
  user: customer
)

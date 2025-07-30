class User < ApplicationRecord
  devise \
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :omniauthable,
    omniauth_providers: [ :google_oauth2 ]

  enum :role, [ :customer, :admin ]

  after_initialize :set_default_columns, if: :new_record?

  # === Constants ===
  DISPLAY_NAME_LENGTH = 30
  BIOGRAPHY_LENGTH = 200

  # === Validations ===
  validates :display_name,
    presence: true,
    length: { maximum: DISPLAY_NAME_LENGTH }

  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false }

  validates :role,
    presence: true,
    inclusion: { in: roles }

  validates :biography,
    length: { maximum: BIOGRAPHY_LENGTH }

  validates :profile_picture,
    content_type: [ "image/png" ],
    if: -> { profile_picture.attached? }

  # === Associations ===
  has_one_attached :profile_picture, dependent: :destroy

  has_many :hearts, class_name: "Track::Heart"
  has_many :hearted_tracks, through: :hearts, source: :track
  has_many :track_plays, class_name: "Track::Play"
  has_many :comments, dependent: :destroy
  has_many :comment_interactions, class_name: "Comment::Interaction"

  class << self
    def from_omniauth(auth)
      user = find_by(provider: auth.provider, uid: auth.uid)

      # try to find by email if no providers
      if user.nil? && auth.info.email
        user = find_by(email: auth.info.email)
        user.update!(provider: auth.provider, uid: auth.uid) if user
      end

      # create new user if email or providers not found
      user ||= create!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        display_name: auth.info.name,
        username: Users::GenerateUsernameService.new.generate_from_display_name(auth.info.name),
        password: Devise.friendly_token[0, 20],
        confirmed_at: Time.current
      )

      # could implement better logic to check if pfp is updated, user manually uploaded pfp, etc.
      # but this is not important, could be future improvement
      unless user.profile_picture.attached?
        user.attach_remote_pfp(auth.info.image)
      end

      user
    end
  end

  def hearted?(track)
    hearted_tracks.exists?(track.id)
  end

  def attach_remote_pfp(url)
    response = Faraday.get(url)
    return unless response.success?

    filename = File.basename(URI.parse(url).path)

    profile_picture.attach(
      io: StringIO.new(response.body),
      filename: filename,
      content_type: response.headers["content-type"]
    )
  end

  private

  def set_default_columns
    self.role ||= User.roles[:customer]
  end
end

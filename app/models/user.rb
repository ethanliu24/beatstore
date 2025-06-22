class User < ApplicationRecord
  devise \
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :omniauthable,
    omniauth_providers: i%[]

  enum :role, [ :customer, :admin ]

  after_initialize :set_default_columns, if: :new_record?

  # === Validations ===
  validates :display_name,
    presence: true

  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false }

  validates :role,
    presence: true,
    inclusion: { in: roles }

  # === Associations ===
  has_one_attached :profile_picture, dependent: :destroy

  has_many :hearts, dependent: :destroy
  has_many :hearted_tracks, through: :hearts, source: :track

  def hearted?(track)
    hearted_tracks.exists?(track.id)
  end

  private

  def set_default_columns
    self.role ||= User.roles[:customer]
  end
end

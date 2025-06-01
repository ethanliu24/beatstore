class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  enum :role, [ :customer, :admin ]

  after_initialize :set_default_columns, if: :new_record?

  # === Validations ===
  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false }

  validates :role,
    presence: true,
    inclusion: { in: roles }

  # === Associations ===
  has_many :hearts, dependent: :destroy
  has_many :hearted_tracks, through: :hearts, source: :track

  private

  def set_default_columns
    self.role ||= User.roles[:customer]
  end
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  enum :role, [ :customer, :admin ]

  after_initialize :set_default_columns, if: :new_record?

  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false }

  validates :role,
    presence: true,
    inclusion: { in: roles }

  def set_default_columns
    self.profile_picture ||= ""
    self.role ||= User.roles[:customer]
  end
end

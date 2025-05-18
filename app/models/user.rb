class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  enum :role, [ :customer, :admin ]

  after_initialize :set_default_columns, if: :new_record?

  PASSWORD_FORMAT = /\A
    (?=.*[A-Z])       # must contain at least one uppercase letter
    (?=.*[a-z])       # must contain at least one lowercase letter
    (?=.*\d)          # must contain at least one digit
    (?=.*[^A-Za-z0-9])# must contain at least one special character
    .{8,}             # must be at least 8 characters long
  \z/x

  # === Validations ===
  validates :password,
    presence: true,
    length: { in: Devise.password_length },
    format: {
      with: PASSWORD_FORMAT,
      message: "Must include at least 8 characters, one uppercase letter, one lowercase letter, one digit, and one special character"
    },
    confirmation: true,
    on: :create

  validates :password,
    allow_nil: true,
    length: { in: Devise.password_length },
    format: {
      with: PASSWORD_FORMAT,
      message: "Must include at least 8 characters, one uppercase letter, one lowercase letter, one digit, and one special character"
    },
    confirmation: true,
    on: :update

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

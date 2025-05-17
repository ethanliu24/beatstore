class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  enum :role, { customer: 0, admin: 1 }

  PASSWORD_FORMAT = /\A
    (?=.{8,})           # At least 8 characters
    (?=.*\d)            # Contains a digit
    (?=.*[a-z])         # Contains a lowercase letter
    (?=.*[A-Z])         # Contains an uppercase letter
    (?=.*[[:^alnum:]])  # Contains a symbol
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

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format." }

  validates :username,
    presence: true,
    uniqueness: { case_sensitive: false }

  validates :role,
    presence: true,
    inclusion: { in: roles.keys }
end

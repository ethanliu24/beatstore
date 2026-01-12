# frozen_string_literal: true

class Contact < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
  validates :subject, presence: true
  validates :message, presence: true

  belongs_to :user, optional: true
end

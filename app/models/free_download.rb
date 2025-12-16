# frozen_string_literal: true

class FreeDownload < ApplicationRecord
  validates :email, presence: true
  validates :customer_name, presence: true

  belongs_to :user, optional: true
  belongs_to :track, optional: true
end

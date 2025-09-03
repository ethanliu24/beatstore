# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user, optional: false

  has_many :cart_items
end

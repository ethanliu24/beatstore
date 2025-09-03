# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user, optional: false

  has_many :items, class_name: CartItem.name, dependent: :destroy
end

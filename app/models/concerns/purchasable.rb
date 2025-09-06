# frozen_string_literal: true

module Purchasable
  extend ActiveSupport::Concern

  class_methods do
    def valid_product_types
      [ Track ].map(&:name)
    end
  end
end

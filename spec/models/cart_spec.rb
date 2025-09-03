# frozen_string_literal

require "rails_helper"

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should belong_to(:user).required }
    it { should have_many(:items) }
  end

  describe "dependent behavior" do
    it "destroys associated cart_items when destroyed" do
      user = create(:user)
      cart = create(:cart, user:)
      create(:cart_item, cart:)

      expect { cart.destroy }.to change { CartItem.count }.by(-1)
    end
  end
end

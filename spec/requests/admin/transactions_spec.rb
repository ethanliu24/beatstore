# spec/requests/admin/transactions_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Transactions", type: :request, admin: true do
  let!(:customer) { create(:user) }

  describe "#index" do
    let!(:order1) { create(:order, user: customer) }
    let!(:order2) { create(:order, user: customer) }
    let!(:order3) { create(:order, user: customer) }
    let!(:transaction1) { create(:payment_transaction, order: order1, created_at: 2.days.ago) }
    let!(:transaction2) { create(:payment_transaction, order: order2, created_at: 1.day.ago) }
    let!(:transaction3) { create(:payment_transaction, order: order3, created_at: Time.current) }

    it "returns a successful response" do
      get admin_transactions_url
      expect(response).to have_http_status(:ok)
    end

    it "lists transactions in descending order of created_at" do
      get admin_transactions_url
      expect(assigns(:transactions)).to eq([transaction3, transaction2, transaction1])
    end

    it "should not let non admins visit" do
      [ :user, :guest ].each do |user_obj|
        user = create(user_obj, email: "#{user_obj}show@email.com", username: "#{user_obj}index")
        sign_in user, scope: :user
        get admin_transactions_url
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#show" do
    let!(:order) { create(:order, user: customer) }
    let!(:transaction) { create(:payment_transaction, order:, order: order) }

    it "returns a successful response and assigns the right attributes" do
      get admin_transaction_url(transaction)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
      expect(assigns(:transaction)).to eq(transaction)
      expect(assigns(:order)).to eq(order)
    end

    it "raises an error for a missing transaction" do
      get admin_transaction_url(id: Transaction.count + 1)
      expect(response).to have_http_status(:not_found)
    end

    it "should not let non admins visit" do
      [ :user, :guest ].each do |user_obj|
        user = create(user_obj, email: "#{user_obj}show@email.com", username: "#{user_obj}show")
        sign_in user, scope: :user
        get admin_transaction_url(transaction)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

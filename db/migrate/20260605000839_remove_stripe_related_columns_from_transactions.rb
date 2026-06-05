class RemoveStripeRelatedColumnsFromTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :payment_processor, :string, null: false

    remove_column :transactions, :stripe_charge_id, :string
    remove_column :transactions, :stripe_receipt_url, :string
  end
end

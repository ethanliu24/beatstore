class AddTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :status, null: false
      t.string :idempotency_key
      t.bigint :stripe_id
      t.string :stripe_receipt_url
      t.string :customer_email
      t.string :customer_name
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.references :order, null: true

      t.timestamps
    end
  end
end

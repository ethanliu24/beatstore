class AddOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :subtotal_cents, null: false, default: 0
      t.string  :currency, null: false, default: "usd"
      t.string :status, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end

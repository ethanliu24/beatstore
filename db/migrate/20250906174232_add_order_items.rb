class AddOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.boolean :is_immutable, null: false, default: false
      t.integer :quantity, null: false, default: 1
      t.references :order, null: false, foreign_key: true

      # snapshots
      t.integer :unit_price_cents, null: false
      t.string :currency, null: false
      t.string :product_type, null: false
      t.jsonb :product_snapshot, default: {}, null: false
      t.jsonb :license_snapshot, default: {}, null: false

      t.timestamps
    end
  end
end

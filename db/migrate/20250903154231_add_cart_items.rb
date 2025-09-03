class AddCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items do |t|
      t.integer :quantity
      t.references :cart, null: false, foreign_key: true
      t.references :product, polymorphic: true, null: true
      t.references :license, null: true, foreign_key: true

      t.timestamps
    end
  end
end

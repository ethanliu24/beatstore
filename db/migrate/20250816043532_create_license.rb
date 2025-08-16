class CreateLicense < ActiveRecord::Migration[8.0]
  def change
    create_table :licenses do |t|
      t.string :title, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.string :currency, limit: 3, null: false, default: "USD"
      t.string :contract_type, null: false
      t.jsonb :contract_details, null: false, default: {}
      t.boolean :default_for_new, null: false, default: false

      t.timestamps
    end

    add_index :licenses, :title, unique: true
  end
end

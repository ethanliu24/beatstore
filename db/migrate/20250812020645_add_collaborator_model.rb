class AddCollaboratorModel < ActiveRecord::Migration[8.0]
  def change
    create_table :collaborators do |t|
      t.string :name, null: false
      t.string :role, null: false
      t.decimal :profit_share, precision: 5, scale: 2, null: false, default: 0
      t.decimal :publishing_share, precision: 5, scale: 2, null: false, default: 0
      t.text :notes, null: true
      t.references :entity, polymorphic: true, null: false

      t.timestamps
    end
  end
end

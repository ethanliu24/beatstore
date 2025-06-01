class CreateHearts < ActiveRecord::Migration[8.0]
  def change
    create_table :hearts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true

      t.timestamps
    end

    add_index :hearts, [ :user_id, :track_id ], unique: true
  end
end

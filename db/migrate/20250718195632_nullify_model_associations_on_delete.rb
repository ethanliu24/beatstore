class NullifyModelAssociationsOnDelete < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :track_hearts, :users
    remove_foreign_key :track_hearts, :tracks
    remove_foreign_key :track_plays, :users
    remove_foreign_key :track_plays, :tracks

    add_foreign_key :track_hearts, :users, on_delete: :nullify
    add_foreign_key :track_hearts, :tracks, on_delete: :nullify
    add_foreign_key :track_plays, :users, on_delete: :nullify
    add_foreign_key :track_plays, :tracks, on_delete: :nullify

    change_column_null :track_hearts, :user_id, true
    change_column_null :track_hearts, :track_id, true
    change_column_null :track_plays, :user_id, true
    change_column_null :track_plays, :track_id, true
  end
end

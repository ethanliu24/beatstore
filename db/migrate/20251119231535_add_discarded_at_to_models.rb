class AddDiscardedAtToModels < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at

    add_column :tracks, :discarded_at, :datetime
    add_index :tracks, :discarded_at

    add_column :comments, :discarded_at, :datetime
    add_index :comments, :discarded_at

    add_column :licenses, :discarded_at, :datetime
    add_index :licenses, :discarded_at
  end
end

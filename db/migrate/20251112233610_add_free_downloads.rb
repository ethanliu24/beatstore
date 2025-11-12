class AddFreeDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :free_downloads do |t|
      t.references :user, null: true, foreign_key: true
      t.references :track, null: true, foreign_key: true

      t.timestamps
    end
  end
end

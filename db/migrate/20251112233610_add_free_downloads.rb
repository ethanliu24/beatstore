class AddFreeDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :free_downloads do |t|
      t.references :user, null: true, foreign_key: { on_delete: :nullify }
      t.references :track, null: true, foreign_key: { on_delete: :nullify }

      t.timestamps
    end
  end
end

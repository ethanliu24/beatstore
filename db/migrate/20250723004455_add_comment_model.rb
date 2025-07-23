class AddCommentModel < ActiveRecord::Migration[8.0]
  create_table :comments do |t|
    t.text :content, null: false
    t.references :entity, polymorphic: true, null: false
    t.references :user, null: false, foreign_key: true

    t.timestamps
  end
end

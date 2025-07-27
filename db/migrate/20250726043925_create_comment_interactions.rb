class CreateCommentInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table :comment_interactions do |t|
      t.string :interaction_type, default: "like"
      t.references :comment, null: false, foreign_key: true
      t.references :user, null: true

      t.timestamps
    end

    add_foreign_key :comment_interactions, :users, column: :user_id, on_delete: :nullify
  end
end

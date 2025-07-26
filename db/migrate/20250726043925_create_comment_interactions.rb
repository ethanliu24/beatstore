class CreateCommentInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table :comment_interactions do |t|
      t.string :type, default: "like"
      t.references :comment, null: false, foreign_key: true
      t.timestamps
    end
  end
end

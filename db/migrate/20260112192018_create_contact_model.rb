class CreateContactModel < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.string :message, null: false

      t.references :user, null: true, foreign_key: { on_delete: :nullify }

      t.timestamps
    end
  end
end

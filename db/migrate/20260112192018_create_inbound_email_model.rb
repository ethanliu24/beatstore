class CreateInboundEmailModel < ActiveRecord::Migration[8.0]
  def change
    create_table :inbound_emails do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text :message, null: false

      t.timestamps
    end
  end
end

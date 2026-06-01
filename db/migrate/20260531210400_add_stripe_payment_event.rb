class AddStripePaymentEvent < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_payment_events do |t|
      t.string :event_id, null: false, index: { unique: true }

      t.references :order, foreign_key: true, null: true
      t.references :user, foreign_key: true, null: true

      t.timestamps
    end
  end
end

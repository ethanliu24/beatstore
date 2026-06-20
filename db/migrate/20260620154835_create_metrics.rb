class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.string :event_name, null: false
      t.jsonb :tags, default: {}
      t.datetime :prunes_at
      t.datetime :created_at
    end

    add_index :metrics, [ :event_name, :created_at ]
    add_index :metrics, :prunes_at
    add_index :metrics, :tags, using: :gin, opclass: :jsonb_path_ops
  end
end

class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.string :event_name, null: false
      t.boolean :prune_after_time, default: true
      t.jsonb :tags, default: {}
      t.datetime :time
    end

    add_index :metrics, [ :event_name, :tags ]
    add_index :metrics, :tags, using: :gin, opclass: :jsonb_path_ops
  end
end

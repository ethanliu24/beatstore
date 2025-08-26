class CreateLicenseAndTrackJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :licenses_tracks, id: false do |t|
      t.references :license, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
    end

    add_index :licenses_tracks, [ :license_id, :track_id ], unique: true
  end
end

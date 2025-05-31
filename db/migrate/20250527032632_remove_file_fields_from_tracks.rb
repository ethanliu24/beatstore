class RemoveFileFieldsFromTracks < ActiveRecord::Migration[8.0]
  def change
    remove_column :tracks, :tagged_mp3, :string
    remove_column :tracks, :untagged_mp3, :string
    remove_column :tracks, :untagged_wav, :string
    remove_column :tracks, :track_stems, :string
    remove_column :tracks, :cover_photo, :string
  end
end

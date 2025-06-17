module TrackAdminHelper
  def generate_id(file_for)
    file_for.downcase.split(" ").join("-") + "-upload"
  end

  def track_upload_style(attachment)
    has_attachment = "bg-accent dark:bg-accent dark:text-white text-white border-none"
    no_attachment = "border-1 dark:border-none border-secondary-txt/30 dark:bg-secondary-bg"
    attachment.attached? ? has_attachment : no_attachment
  end

  def key_options
    keys = [
      "C", "C#",
      "D", "D#", "Db",
      "E", "Eb",
      "F", "F#",
      "G", "G#", "Gb",
      "A", "A#", "Ab",
      "B", "Bb"
    ]
    scales = [ "MAJOR", "MINOR" ]

    [ nil ] + keys.product(scales).map do |key, scale|
      "#{key} #{scale}"
    end
  end

  def is_public_options
    [
      [ "Public", true ],
      [ "Private", false ]
    ]
  end

  def genre_options
    Track::GENRES
  end

  def max_description_length
    Track::MAX_DESCRIPTION_LENGTH
  end

  def serialize_tags(track)
    track.tags.map { |t| { id: t.id, name: t.name } }.to_json
  end

  def track_file_upload_indicator_styles(file)
    uploaded = "text-success bg-success/20"
    missing = "text-error bg-error/20"
    "px-1 py-0.5 rounded #{file.attached? ? uploaded : missing}"
  end

  def track_more_dropdown_id(track)
    "admin-track-#{track.id}-more-dropdown"
  end
end

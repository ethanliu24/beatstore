module TrackUploadHelper
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
end

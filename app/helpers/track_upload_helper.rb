module TrackUploadHelper
  def generate_id(file_for)
    file_for.downcase.split(" ").join("-") + "-upload"
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

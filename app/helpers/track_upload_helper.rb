module TrackUploadHelper
  def generate_id(file_for)
    file_for.downcase.split(" ").join("-") + "-upload"
  end
end

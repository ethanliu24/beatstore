module TrackHelper
  def get_tags_for(track)
    track.tags.map { |t| "##{t.name}" }
  end
end

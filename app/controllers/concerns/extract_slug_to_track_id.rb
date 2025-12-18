# frozen_string_literal: true

module ExtractSlugToTrackId
  extend ActiveSupport::Concern

  def extract_track_id(param_id)
    return -1 if param_id.blank?

    param_id.to_s.split(Track::SLUG_SEPERATOR).last.to_i
  end
end

# frozen_string_literal: true

module ExtractSlugToTrackId
  extend ActiveSupport::Concern

  def extract_track_id(slug)
    return -1 if slug.blank?

    slug.to_s.split("-").last.to_i
  end
end

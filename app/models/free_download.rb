# frozen_string_literal: true

class FreeDownload
  belongs_to :user, optional: true
  belongs_to :track, optional: true
end

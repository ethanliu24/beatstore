# forzen_string_literal: true

class TakeLicenseSnapshotService
  def initialize(license:)
    @license = license
  end

  def call
    @license.attributes
  end
end

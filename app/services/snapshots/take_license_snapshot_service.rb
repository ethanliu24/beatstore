# frozen_string_literal: true

module Snapshots
  class TakeLicenseSnapshotService
    def initialize(license:)
      @license = license
    end

    def call
      @license.attributes
    end
  end
end

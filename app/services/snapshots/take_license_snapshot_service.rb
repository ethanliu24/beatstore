# frozen_string_literal: true

module Snapshots
  class TakeLicenseSnapshotService
    def initialize(license:)
      @license = license
    end

    def call
      snapshot = @license.attributes

      snapshot.delete("default_for_new")

      snapshot
    end
  end
end

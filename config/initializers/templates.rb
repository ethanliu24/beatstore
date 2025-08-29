# frozen_string_literal: true

class Templates
  class << self
    def read_contract_templates
      {
        track_free: read_templates("templates/contracts/tracks/free.md"),
        track_non_exclusive: read_templates("templates/contracts/tracks/non_exclusive.md")
      }
    end

    private

    def read_templates(file_name)
      File.exist?(file_name) ? File.read(file_name) : ""
    end
  end
end

Rails.configuration.templates = {}
Rails.configuration.templates[:contracts] = Templates.read_contract_templates

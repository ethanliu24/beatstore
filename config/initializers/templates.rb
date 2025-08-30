# frozen_string_literal: true

class Templates
  class << self
    def read_contract_templates
      track_free = License.contract_types[:free]
      track_non_exclusive = License.contract_types[:free]

      {
        "#{track_free}" => read_template("templates/contracts/tracks/free.md"),
        "#{track_non_exclusive}" => read_template("templates/contracts/tracks/non_exclusive.md")
      }.with_indifferent_access
    end

    private

    def read_template(file_name)
      File.exist?(file_name) ? File.read(file_name) : ""
    end
  end
end

Rails.application.config.to_prepare do
  Rails.configuration.templates = {}
  Rails.configuration.templates[:contracts] = Templates.read_contract_templates
end

# frozen_string_literal: true

module Templates
  class ContractTemplates
    extend Templates::Reader

    class << self
      def read_contract_templates
        track_free = License.contract_types[:free]
        track_non_exclusive = License.contract_types[:non_exclusive]
        track_exclusive = License.contract_types[:exclusive]

        {
          "#{track_free}" => read_template("templates/contracts/tracks/free.md"),
          "#{track_non_exclusive}" => read_template("templates/contracts/tracks/non_exclusive.md"),
          "#{track_exclusive}" => read_template("templates/contracts/tracks/exclusive.md")
        }.with_indifferent_access
      end
    end
  end
end

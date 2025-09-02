# frozen_string_literal: true

module Contracts
  class ConstructTracksContractContents
    def initialize(license:, track:)
      @license = license
      @contract = license.contract
      @track = track
      # TODO pass in customer fields
    end

    def call
      case @license.contract_type
      when License.contract_types[:free]
        contents = construct_free_contract
      when License.contract_types[:non_exclusive]
        contents = {}
      else
        contents = {}
      end

      RenderTemplateService.new(template: @contract[:document_template], contents:).call
    end

    private

    def construct_free_contract
      {
        "LICENSE_NAME": @license.title,
        "CONTRACT_DATE": Date.today,
        "PRODUCT_OWNER_FULLNAME": "Yichen Liu",
        "PRODUCER_ALIAS": "prodethan",
        "CUSTOMER_FULLNAME": "UNKNOWN",  # TODO
        "CUSTOMER_ADDRESS": "UNKNOWN",  # TODO
        "TERMS_OF_YEARS": @contract[:terms_of_years],
        "PUBLISHING_SHARES": "50%",
        "TRACK_CONTRIBUTOR_ALIASES": format_collaborators,
        "STATE_PROVINCE_COUNTRY": format_country
      }
    end

    def format_country
      country = ISO3166::Country[@license.country]
      region = country.subdivisions[@license.province]

      region.present? ? "#{region["name"]}, #{country.iso_long_name}" : country.iso_long_name
    end

    def format_collaborators
      collaborators = [ "prodethan" ]
      return collaborators if @track.nil?

      @track.collaborators.each do |c|
        collaborators.push(c.name)
      end

      collaborators.join(", ")
    end
  end
end

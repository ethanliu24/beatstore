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
        contents = construct_non_exclusive_contract
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

    def construct_non_exclusive_contract
      {
        "LICENSE_NAME": @license.title,
        "CONTRACT_DATE": Date.today,
        "PRODUCT_OWNER_FULLNAME": "Yichen Liu",
        "PRODUCER_ALIAS": "prodethan",
        "CUSTOMER_FULLNAME": "UNKNOWN",  # TODO
        "CUSTOMER_ADDRESS": "UNKNOWN",  # TODO
        "PRODUCT_TITLE": @track.present? ? @track.title : "UNKNOWN",
        "PRODUCT_PRICE": "#{@license.price.format} #{@license.currency}",
        "FILE_TYPE": file_type_delivered,
        "TERMS_OF_YEARS": @contract[:terms_of_years],
        "DISTRIBUTE_COPIES": @contract[:distribution_copies],
        "AUDIO_STREAMS": @contract[:streams_allowed],
        "MONETIZED_MUSIC_VIDEOS": @contract[:monetized_videos],
        "NON_MONETIZED_MUSIC_VIDEOS": @contract[:non_monetized_videos],
        "HAS_BROADCASTING_RIGHT": @contract[:has_broadcasting_rights],
        "NUMBER_OF_RADIO_STATIONS": @contract[:radio_stations_allowed],
        "INCLUDING_OR_NOT_INCLUDING_PERFOMANCES": (@contract[:allow_profitable_performances] ? "" : "NOT ") + "INCLUDING",
        "NON_PROFITABLE_PERFORMANCES_ALLOWED": @contract[:non_profitable_performances_allowed],
        "TRACK_CONTRIBUTOR_ALIASES": format_collaborators,
        "SAMPLES": format_samples,
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

    def format_samples
      return "NO THIRD PARTY SAMPLES USED ON THIS TRACK" if @track.nil?

      samples = []
      @track.samples.each do |s|
        samples << "- #{s.name} - #{s.artist}"
      end

      samples.join("\n")
    end

    def file_type_delivered
      if @contract[:delivers_wav] || @contract[:delivers_stems]
        "WAV"
      else
        "MP3"
      end
    end
  end
end

module LicenseHelper
  def contract_name(contract_type)
    t("admin.license.contract_name", contract: t("contracts.tracks.#{contract_type}"))
  end

  def price_with_currency(license)
    "#{license.price.format} #{license.currency}"
  end

  def track_files_delivered(license)
    return "Free MP3" if license.contract_type == License.contract_types[:free]

    files = []
    files << "MP3" if license.contract[:delivers_mp3]
    files << "WAV" if license.contract[:delivers_wav]
    files << "Stems" if license.contract[:delivers_stems]

    files.empty? ? "N/A" : files.join(", ")
  end

  def license_applied_to_track?(track:, license:)
    if controller_name == "tracks"
      if action_name == "new"
        license.default_for_new || track.licenses.include?(license)
      else
        track.licenses.include?(license)
      end
    end
  end

  def get_license_overview(license)
    overview = []
    contract = license.contract

    if contract[:delivers_mp3]
      tagged = license.contract_type == License.contract_types[:free]
      overview << "1 MP3 File (#{tagged ? "Tagged" : "Untagged"})"
    end

    if contract[:delivers_wav]
      overview << "1 WAV File (Untagged)"
    end

    if contract[:delivers_stems]
      overview << "Trackout/Stems"
    end

    if contract.key?(:streams_allowed)
      if contract[:streams_allowed].nil?
        overview << "Unlimited Streams Cap"
      elsif contract[:streams_allowed] > 0
        overview << "#{contract[:streams_allowed]} Streams Cap"
      end
    end

    if contract.key?(:distribution_copies)
      if contract[:distribution_copies].nil?
        overview << "Unlimited Units Cap"
      elsif contract[:distribution_copies] > 0
        overview << "#{contract[:distribution_copies]} Units Cap"
      end
    end

    if contract.key?(:streams_allowed)
      if contract[:streams_allowed].nil?
        overview << "Unlimited Monetized MVs Cap"
      elsif contract[:streams_allowed] > 0
        overview << "#{contract[:streams_allowed]} Monetized MVs Cap"
      end
    end

    if contract.key?(:monetized_videos)
      if contract[:monetized_videos].nil?
        overview << "Unlimited Monetized Music Videos"
      elsif contract[:monetized_videos] > 0
        overview << "#{contract[:monetized_videos]} Monetized MV Cap"
      end
    end

    if contract.key?(:radio_stations_allowed)
      if contract[:radio_stations_allowed].nil?
        overview << "Unlimited Radio Stations Cap"
      elsif contract[:radio_stations_allowed] > 0
        overview << "#{contract[:radio_stations_allowed]} Radio Stations Cap"
      end
    end

    overview << "Must credit in title (Prod. prodethan)"

    overview
  end
end

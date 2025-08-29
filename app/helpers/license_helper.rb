module LicenseHelper
  def contract_name(contract_type)
    t("admin.license.contract_name", contract: t("contracts.tracks.#{contract_type}"))
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
end

module LicenseHelper
  def contract_name(contract_type)
    t("admin.license.contract_name", contract: t("contracts.tracks.#{contract_type}"))
  end
end

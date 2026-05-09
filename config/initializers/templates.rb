Rails.application.config.to_prepare do
  Rails.configuration.templates = {}
  Rails.configuration.templates[:contracts] = Templates::ContractTemplates.read_contract_templates

  Rails.configuration.legal = {}
  Rails.configuration.legal[:terms_of_service] = Templates::LegalTemplates.read_tos
  Rails.configuration.legal[:privacy_policy] = Templates::LegalTemplates.read_privacy
  Rails.configuration.legal[:cookies_policy] = Templates::LegalTemplates.read_cookies
end

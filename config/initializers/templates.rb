Rails.application.config.to_prepare do
  Rails.configuration.templates = {}
  Rails.configuration.templates[:contracts] = Templates.read_contract_templates

  Rails.configuration.legal = {}
  Rails.configuration.legal[:terms_of_service] = LegalTemplates.read_tos
  Rails.configuration.legal[:privacy_policy] = LegalTemplates.read_privacy
  Rails.configuration.legal[:cookies_policy] = LegalTemplates.read_cookies
end

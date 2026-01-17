class ApplicationMailer < ActionMailer::Base
  default from: -> { ::Credentials::Email.domain_email }
  layout "mailer"
end

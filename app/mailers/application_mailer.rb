class ApplicationMailer < ActionMailer::Base
  default from: EmailCredentials.domain_email
  layout "mailer"
end

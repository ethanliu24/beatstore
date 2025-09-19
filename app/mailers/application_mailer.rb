class ApplicationMailer < ActionMailer::Base
  # TODO change to domain name
  default from: "from@example.com"
  layout "mailer"
end

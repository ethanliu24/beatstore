class ContactMailer < ApplicationMailer
  default to: PRODUCER_EMAIL
  default from: DOMAIN_EMAIL

  def contact
    inbound_email = params[:inbound_email]

    @name = inbound_email.name
    @message = inbound_email.message
    @subject = inbound_email.subject

    sender_email = inbound_email.email

    mail(subject: @subject, reply_to: sender_email, cc: DOMAIN_EMAIL)
  end
end

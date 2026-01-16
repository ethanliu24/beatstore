class ContactMailer < ApplicationMailer
  def contact
    inbound_email = params[:inbound_email]

    @name = inbound_email.name
    @message = inbound_email.message
    @subject = inbound_email.subject

    sender_email = inbound_email.email

    mail(
      subject: @subject,
      to: ::Credentials::Email.producer_email,
      reply_to: sender_email,
      cc: ::Credentials::Email.domain_email
    )
  end
end

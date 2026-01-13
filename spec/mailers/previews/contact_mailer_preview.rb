# Preview all emails at http://localhost:3000/rails/mailers

class ContactMailerPreview < ActionMailer::Preview
  def contact
    inbound_email = InboundEmail.new(
      name: "A", email: "a@a", subject: "Test", message: "Hey, \n\nTest test test."
    )

    ContactMailer.with(inbound_email:).contact
  end
end

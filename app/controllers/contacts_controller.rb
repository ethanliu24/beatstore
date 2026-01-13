# frozen_string_literal: true

class ContactsController < ApplicationController
  def new
    render
  end

  def create
    email_data = sanaitize_contact_params
    inbound_email = InboundEmail.new(**email_data)

    @success = inbound_email.save
    if @success
      flash.now[:notice] = t("contact.create.success")
      ContactMailer.with(inbound_email:).contact.deliver_later
    end
  end

  private

  def sanaitize_contact_params
    params.require(:inbound_email).permit(:name, :email, :subject, :message)
  end
end

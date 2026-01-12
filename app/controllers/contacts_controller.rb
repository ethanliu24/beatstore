# frozen_string_literal: true

class ContactsController < ApplicationController
  def new
    render
  end

  def create
    email_data = sanaitize_contact_params
    contact = InboundEmail.new(user: current_user, **email_data)

    @success = contact.save
    if contact.save
      flash.now[:notice] = t("contact.create.success")
    end
  end

  private

  def sanaitize_contact_params
    params.require(:inbound_email).permit(:name, :email, :subject, :message)
  end
end

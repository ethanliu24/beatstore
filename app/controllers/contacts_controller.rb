# frozen_string_literal: true

class ContactsController < ApplicationController
  def new
  end

  def create
    email_data = sanaitize_contact_params
    contact = InboundEmail.new(user: current_user, **email_data)

    respond_to do |format|
      if contact.save
        flash.now[:notice] = t("contact.create.success")
      else
        flash.now[:warning] = t("contact.create.failure")
      end

      format.turbo_stream { render turbo_stream: turbo_stream.update("toasts", partial: "shared/toasts") }
    end
  end

  private

  def sanaitize_contact_params
    params.require(:inbound_email).permit(:name, :email, :subject, :message)
  end
end

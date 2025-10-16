class PurchaseMailer < ApplicationMailer
  def purchase_complete
    @user = params[:user]
    @order = params[:order]
    @transaction = @order.payment_transaction

    subject = "Thank you for your purchase"

    recipients = [ @user.email, @transaction&.customer_email ].compact
    mail(to: recipients, subject:)
  end
end

class PurchaseMailer < ApplicationMailer
  def purchase_complete
    @user = params[:user]
    @order = params[:order]
    @transaction = @order.payment_transaction

    subject = "Thank you for your purchase"
    mail(to: @user.email, subject:)

    if @transaction.customer_email.present?
      mail(to: @transaction.customer_email, subject:)
    end
  end
end

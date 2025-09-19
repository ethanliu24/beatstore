class PurchaseMailer < ApplicationMailer
  def purchase_complete_email
    @user = params[:user]
    @order = params[:order]
    # mail(to: @user.email, subject: "")
  end
end

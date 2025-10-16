# Preview all emails at http://localhost:3000/rails/mailers/purchase_mailer
class PurchaseMailerPreview < ActionMailer::Preview
  def purchase_complete
    user = User.first || User.new(email: "purchase_complete@example.com", display_name: "Test User")
    order = Order.last || Order.new

    PurchaseMailer.with(user: user, order: order).purchase_complete
  end
end

# frozen_string_literal: true

class OrderFulfillmentInputSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(input)
    super(
      "order_id" => input.order.id,
      "customer_email" => input.customer_email,
      "customer_name" => input.customer_name,
      "amount_cents" => input.amount_cents,
      "currency" => input.currency,
      "stripe_charge_id" => input.stripe_charge_id,
    )
  end

  def deserialize(hash)
    order = Order.find(hash["order_id"])
    FulfillOrderService::Input.new(
      order:,
      customer_email: hash["customer_email"],
      customer_name: hash["customer_name"],
      amount_cents: hash["amount_cents"],
      currency: hash["currency"],
      stripe_charge_id: hash["stripe_charge_id"],
    )
  end

  def kclass
    FulfillOrderService::Input
  end
end

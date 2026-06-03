# frozen_string_literal: true

class OrderFulfillmentSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(input)
    super(
      "order_id" => input.order.id,
      "customer_email" => input.customer_email,
      "customer_name" => customer_name,
      "amount_cents" => amount_cents,
      "currency" => currency,
      "stripe_charge_id" => stripe_charge_id,
    )
  end

  def deserialize(hash)
    order = Order.find(h["order_id"])
    FulfillOrderService::Input.nw(
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

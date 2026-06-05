# frozen_string_literal: true

class OrderFulfillmentInputSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize?(input)
    input.is_a?(FulfillOrderService::Input)
  end

  def serialize(input)
    super(
      "order_id" => input.order.id,
      "customer_email" => input.customer_email,
      "customer_name" => input.customer_name,
      "amount_cents" => input.amount_cents,
      "currency" => input.currency
    )
  end

  def deserialize(hash)
    order = Order.find(hash["order_id"])
    FulfillOrderService::Input.new(
      order:,
      customer_email: hash["customer_email"],
      customer_name: hash["customer_name"],
      amount_cents: hash["amount_cents"],
      currency: hash["currency"]
    )
  end

  def kclass
    FulfillOrderService::Input
  end
end

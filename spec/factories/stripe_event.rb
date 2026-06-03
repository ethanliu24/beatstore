# spec/factories/stripe_events.rb

FactoryBot.define do
  factory :stripe_checkout_session_completed_event, class: Stripe::Event do
    transient do
      event_id { "evt_123" }
      session_id { "co_test_123" }
      customer_email { "email@example.com" }
      customer_name { "Customer" }
      amount_total { 9999 }
      currency { "usd" }
    end

    skip_create

    initialize_with do
      Stripe::Event.construct_from(
        id: event_id,
        type: "checkout.session.completed",
        data: {
          object: {
            id: session_id,
            customer_details: {
              email: customer_email,
              name: customer_name
            },
            amount_total: amount_total,
            currency: currency
          }
        }
      )
    end
  end
end

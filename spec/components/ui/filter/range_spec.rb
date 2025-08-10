# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Filter::RangeComponent, type: :component do
  let(:mock_form) { double("FormBuilder", number_field: "", label: "") }

  it "renders the range inputs" do
    render_inline(
      described_class.new(
        form: mock_form,
        label: "Price",
        lb_query: :price_gteq,
        ub_query: :price_lteq
      )
    )

    expect(page).to have_css("div.flex.justify-center.items-stretch") # container
  end

  it "does not render when render? is false" do
    result = render_inline(
      described_class.new(
        form: mock_form,
        label: "Price",
        lb_query: :price_gteq,
        ub_query: :price_lteq,
        render: false
      )
    )

    expect(result.to_html.strip).to eq("")
  end
end

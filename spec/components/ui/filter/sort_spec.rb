# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::Filter::SortComponent, type: :component do
  let(:mock_q) { double("RansackSearch") }
  let(:sort_data) do
    [
      { field: :name, title: "Name" },
      { field: :created_at, title: "Created" }
    ]
  end

  before do
    allow_any_instance_of(described_class)
      .to receive(:sort_link) do |_, _q, _field, title|
        "<a href='#'>#{title}</a>".html_safe
      end
  end

  it "renders all sort options" do
    render_inline(described_class.new(q: mock_q, sort_data: sort_data))

    expect(rendered_content).to include("Name")
    expect(rendered_content).to include("Created")
  end
end

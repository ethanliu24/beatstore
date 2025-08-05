# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::ModalComponent, type: :component do
  it "renders with default size" do
    rendered = render_inline(described_class.new) do |modal|
      modal.with_header(title: "Header")
      modal.with_body { "Body Content" }
      modal.with_footer { "Footer" }
    end

    expect(rendered.text).to have_content("Body Content")
    expect(rendered).to have_css(".max-w-2xl")
    expect(rendered).to have_css(".modal-header")
    expect(rendered).to have_css(".modal-footer")
  end

  it "renders with size :sm" do
    render_inline(described_class.new(size: :sm)) do |modal|
      modal.with_body { "Small Modal Body" }
    end

    expect(rendered_content).to include("Small Modal Body")
    expect(rendered_content).to include("max-w-md")
  end

  it "falls back to lg size if size is invalid" do
    rendered = render_inline(described_class.new(size: :invalid)) do |modal|
      modal.with_body { "Body Content" }
    end

    expect(rendered).to have_css(".max-w-2xl")
  end
end

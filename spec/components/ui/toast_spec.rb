# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::ToastComponent, type: :component do
  it "renders the message text" do
    message = "Successfully saved!"
    render_inline(described_class.new(type: :notice, message: message))

    expect(page).to have_text(message)
  end

  it "renders the success icon for :notice" do
    render_inline(described_class.new(type: :notice, message: "Success"))

    expect(page).to have_css("svg")
    expect(page).to have_css(".notice-toast")
  end

  it "renders the error icon for :alert" do
    render_inline(described_class.new(type: :alert, message: "Something went wrong"))

    expect(page).to have_css("svg")
    expect(page).to have_css(".alert-toast")
  end

  it "renders a close button with correct action" do
    render_inline(described_class.new(type: :notice, message: "Dismissable"))

    expect(page).to have_selector("button[data-action='click->toast#dismiss']")
    expect(page).to have_text("Dismiss")
  end

  it "has the correct container classes for layout and animation" do
    render_inline(described_class.new(type: :notice, message: "Styled"))

    expect(page).to have_css(".slide-up-fade-in")
    expect(page).to have_css(".notice-toast")
  end
end

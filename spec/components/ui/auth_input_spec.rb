# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::AuthInputComponent, type: :component do
  let(:resource) { create(:user) }
  let(:form) do
    double("FormBuilder",
      label: "<label></label>".html_safe,
      email_field: "<input type='email' name='user[email]'>".html_safe,
      text_field: "<input type='text' name='user[text]'>".html_safe,
      password_field: "<input type='password' name='user[password]'>".html_safe
    )
  end

  it "renders the corresponding correct fields" do
    rendered = render_inline(described_class.new(
      form:, resource:, field: :email, label: :email, type: :email
    ))
    expect(rendered).to have_css("input", count: 1)
    expect(rendered).to have_selector("input[type='email'][name='user[email]']")
    expect(rendered).not_to have_css("text-error")

    rendered = render_inline(described_class.new(
      form:, resource:, field: :password, label: :password, type: :password
    ))
    expect(rendered).to have_css("input", count: 1)
    expect(rendered).to have_selector("input[type='password'][name='user[password]']")
    expect(rendered).not_to have_css("text-error")

    rendered = render_inline(described_class.new(
      form:, resource:, field: :text, label: :text, type: :text
    ))
    expect(rendered).to have_css("input", count: 1)
    expect(rendered).to have_selector("input[type='text'][name='user[text]']")
    expect(rendered).not_to have_css("text-error")
  end

  it "falls back to text field if type is unknow or not allowed" do
    rendered = render_inline(described_class.new(
      form:, resource:, field: :text, label: :text, type: :invalid
    ))
    expect(rendered).to have_css("input", count: 1)
    expect(rendered).to have_selector("input[type='text'][name='user[text]']")
    expect(rendered).not_to have_css("text-error")
  end

  it "renders errors for field if present" do
    user = User.new(email: nil)
    user.save
    rendered = render_inline(described_class.new(
      form:, resource: user, field: :email, label: :email, type: :email
    ))

    expect(rendered).to have_css(".text-error", text: "Email is required")
  end
end

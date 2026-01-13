# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ui::FloatingInputComponent, type: :component do
  let(:field) { :name }
  let(:label) { :label }
  let(:id) { "id" }
  let(:form) do
    double("FormBuilder",
      label: "<label></label>".html_safe,
      email_field: "<input type='email' name='user[email]' autocomplete='off' required>".html_safe,
      text_field: "<input type='text' name='user[text]' autocomplete='off' required>".html_safe,
      text_area: "<textarea name='user[bio]' rows='1' autocomplete='off' required></textarea>".html_safe
    )
  end

  it "renders the correct input types" do
    # email field
    rendered = render_inline(described_class.new(form:, field:, label:, id:, field_type: :email_field))
    expect(rendered).to have_css("input[type='email'][name='user[email]']")
    expect(rendered).to have_css("input[autocomplete='off'][required]")

    # text field
    rendered = render_inline(described_class.new(form:, field:, label:, id:, field_type: :text_field))
    expect(rendered).to have_css("input[type='text'][name='user[text]']")
    expect(rendered).to have_css("input[autocomplete='off'][required]")

    # text area
    rendered = render_inline(described_class.new(form:, field:, label:, id:, field_type: :text_area))
    expect(rendered).to have_css("textarea[name='user[bio]'][rows='1']")
    expect(rendered).to have_css("textarea[autocomplete='off'][required]")
  end
end

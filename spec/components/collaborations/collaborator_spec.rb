# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration::CollaboratorComponent, type: :component do
  let(:track) { create(:track) }
  let(:collaborator) { create(:collaborator, entity: track) }
  let(:rendered) { render_inline(described_class.new(collaborator: collaborator)) }

  it "renders the collaborator name and role correctly" do
    expect(rendered.text).to have_content("Diddy")
    expect(rendered.text).to have_content("Producer")
  end

  it "renders the collaborator notes" do
    expect(rendered.text).to have_content("IG: @diddy")
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrackRecommendation, type: :model do
  let(:subject) { build(:track_recommendation) }

  it { should validate_presence_of(:group) }
  it { should validate_uniqueness_of(:group) }
  it { should validate_length_of(:group).is_at_most(TrackRecommendation::MAX_GROUP_LENGTH) }
  it { should validate_presence_of(:tag_names) }
  it { should have_one_attached(:display_image) }

  it "is valid when tag_names is an array of strings" do
    subject.tag_names = %w[a b c]
    expect(subject).to be_valid
  end

  it "allows png uploads" do
    subject.display_image.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/recommendations/display_image.png")),
      filename: "display_image.png",
      content_type: "image/png"
    )

    expect(subject).to be_valid
  end

  it "rejects non png uploads" do
    subject.display_image.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/recommendations/invalid_image.jpg")),
      filename: "display_image.jpg",
      content_type: "image/jpeg"
    )

    expect(subject).not_to be_valid
    expect(subject.errors[:display_image]).to include(match(/has an invalid content type/))
  end
end

require "rails_helper"

RSpec.describe Track, type: :model do
  describe "validations" do
    subject(:track) { build(:track) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:bpm) }
    it { should validate_numericality_of(:bpm).only_integer.is_greater_than(0) }

    it "is valid with valid attributes" do
      subject.bpm = 120
      subject.key = "C MAJOR"
      expect(subject).to be_valid
    end

    it "only accepts positive integers" do
      subject.bpm = 0
      expect(subject).to be_invalid

      subject.bpm = -1
      expect(subject).to be_invalid

      subject.bpm = 100
      expect(subject).to be_valid
    end

    context "is_public validation" do
      it "coerces non-boolean values to boolean" do
        track = Track.new(is_public: true)
        expect(track.is_public).to be(true)

        track.is_public = nil
        track.save
        expect(track.is_public).to be(false)

        track.is_public = "string"
        expect(track.is_public).to be(true)

        track.is_public = 1
        expect(track.is_public).to be(true)

        track.is_public = false
        expect(track.is_public).to be(false)
      end
    end

    context "key validation" do
      it "accepts valid keys" do
        [ "C MAJOR", "A# MINOR", "Eb MINOR", "Gb MAJOR" ].each do |k|
          subject.key = k
          expect(subject).to be_valid, "#{k} should be valid"
        end
      end

      it "rejects invalid keys" do
        [ "C", "major", "C MAJ", "H MAJOR", "C# Minor", "B DIMINISHED" ].each do |k|
          subject.key = k
          expect(subject).to be_invalid, "#{k} should be invalid"
        end
      end
    end

    context "genre" do
      it "is valid with a valid genre" do
        Track::GENRES.each do |valid_genre|
          subject.genre = valid_genre
          expect(subject).to be_valid
        end
      end

      it "is invalid without a genre" do
        subject.genre = nil
        expect(subject).not_to be_valid
        expect(subject.errors.details[:genre]).to include(hash_including(error: :blank))
      end

      it "is invalid with an unknown genre" do
        subject.genre = "unknown_genre"
        expect(subject).not_to be_valid
        expect(subject.errors.details[:genre]).to include(hash_including(error: :inclusion))
      end
    end

    context "description" do
      it "is valid if description is blank" do
        subject.description = ""
        expect(subject).to be_valid
      end

      it "is valid if description is less than or equal to 200 characters" do
        subject.description = "a" * 200
        expect(subject).to be_valid
      end

      it "is invalid if description is longer than 200 characters" do
        subject.description = "a" * 201
        expect(subject).not_to be_valid
        expect(subject.errors.details[:description]).to include(hash_including(error: :too_long))
      end
    end

    context "file attachments" do
      let(:track_with_files) { build(:track_with_files) }

      it "is valid if no files are attached" do
        expect(subject).to be_valid
      end

      it "is valid if the mime types are correct" do
        expect(track_with_files.tagged_mp3.content_type).to eq("audio/mpeg")
        expect(track_with_files.untagged_mp3.content_type).to eq("audio/mpeg")
        expect(track_with_files.untagged_wav.content_type).to eq("audio/x-wav")
        expect(track_with_files.track_stems.content_type).to eq("application/zip")
        expect(track_with_files.project.content_type).to eq("application/zip")
        expect(track_with_files.cover_photo.content_type).to eq("image/png")
        expect(track_with_files).to be_valid
      end

      it "is invalid if mime types are incorrect" do
        track_with_files.tagged_mp3.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "track_stems.zip")),
          filename: "track_stems.zip",
          content_type: "application/zip"
        )

        track_with_files.cover_photo.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "cover_photo.png")),
          filename: "cover_photo.png",
          content_type: "image/png"
        )

        track_with_files.untagged_wav.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "untagged_mp3.mp3")),
          filename: "untagged_mp3.mp3",
          content_type: "audio/mpeg"
        )

        track_with_files.track_stems.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "untagged_wav.wav")),
          filename: "untagged_wav.wav",
          content_type: "audio/x-wav"
        )

        track_with_files.cover_photo.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
          filename: "tagged_mp3.mp3",
          content_type: "audio/mpeg"
        )

        track_with_files.project.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
          filename: "tagged_mp3.mp3",
          content_type: "audio/mpeg"
        )

        expect(track_with_files).not_to be_valid
      end
    end
  end

  describe "destroy" do
    let(:user) { create(:user) }
    let(:track) { create(:track) }

    it "should successfully destroy track and nullify its play and hearts" do
      heart = create(:track_heart, track_id: track.id, user_id: user.id)
      play = create(:track_play, track_id: track.id, user_id: user.id)

      expect { track.destroy }.to change { Track.count }.by(-1)

      heart.reload
      play.reload

      expect(heart.track_id).to be_nil
      expect(play.track_id).to be_nil
      expect(heart.user_id).to eq(user.id)
      expect(play.user_id).to eq(user.id)
    end

    it "should delete all comments associated with it" do
      create(:comment, entity: track, user: user)
      create(:comment, entity: track, user: user)

      expect(track.comments.size).to eq(2)

      track.destroy!

      expect(track.comments.size).to eq(0)
    end

    it "should delete all collaborators associated with it" do
      create(:collaborator, entity: track)

      expect(track.reload.collaborators.size).to eq(1)

      track.destroy!

      expect(track.collaborators.size).to eq(0)
    end

    it "should delete all tags associated with it" do
      track = create(:track)
      tag1 = create(:track_tag, track: track, name: "t1")
      tag2 = create(:track_tag, track: track, name: "t2")

      expect(track.reload.tags.where(name: "t1").count).to eq(1)
      expect(track.reload.tags.where(name: "t2").count).to eq(1)
      expect { track.destroy }.to change { Track::Tag.count }.by(-2)
      expect(Track::Tag.where(id: [ tag1.id, tag2.id ])).to be_empty
    end
  end

  describe "associations" do
    it { should have_many(:hearts) }
    it { should have_many(:hearted_by_users).through(:hearts).source(:user) }
    it { should have_many(:plays) }
    it { should have_many(:comments) }

    it { should have_one_attached(:tagged_mp3) }
    it { should have_one_attached(:untagged_mp3) }
    it { should have_one_attached(:untagged_wav) }
    it { should have_one_attached(:track_stems) }
    it { should have_one_attached(:project) }
    it { should have_one_attached(:cover_photo) }
    it { is_expected.to have_many(:free_downloads).dependent(:nullify) }

    it "can have many licenses" do
      track = create(:track)
      license1 = create(:license)
      license2 = create(:license, title: "L2")

      track.licenses << [ license1, license2 ]

      expect(track.licenses.count).to eq(2)
      expect(license1.tracks).to include(track)
      expect(license2.tracks).to include(track)
      expect(license1.tracks.count).to eq(1)
      expect(license2.tracks.count).to eq(1)
    end

    it "can have many cart items" do
      cart = create(:cart)
      track = create(:track)
      cart_item = create(:cart_item, cart:, product: track)

      expect(track.cart_items.count).to eq(1)
      expect(track.cart_items.first).to eq(cart_item)
    end

    it "destroying a track nullifies cart's product attribute" do
      cart = create(:cart)
      track = create(:track)
      cart_item = create(:cart_item, cart:, product: track)

      track.destroy!
      cart_item.reload

      expect(cart_item.product).to be_nil
      expect(cart_item.product_id).to be_nil
      expect(cart_item.product_type).to be_nil
      expect(cart_item.available?).to be(false)
    end

    it "nullifies track_id in free_downloads when track is destroyed" do
      track = create(:track)
      free_download = create(:free_download, track:)

      expect { track.destroy }.to change {
        free_download.reload.track_id
      }.from(track.id).to(nil)

      expect { track.destroy }.not_to change(FreeDownload, :count)
      expect(free_download.reload).to be_persisted
    end

    it "destroying track also destroys licenses associations" do
      track = create(:track)
      license = create(:license)
      track.licenses << license

      expect(Licenses::LicensesTracksAssociation.count).to eq(1)

      track.destroy!

      expect(track.licenses.count).to eq(0)
      expect(license.tracks.count).to eq(0)
      expect(Licenses::LicensesTracksAssociation.count).to eq(0)
    end
  end

  describe "#cheapest_price" do
    let(:track) { create(:track) }

    it "should return cheapest price of profitable licenses" do
      l1 = create(:non_exclusive_license, price_cents: 1000)
      l2 = create(:non_exclusive_license, title: "T2", price_cents: 2000)
      track.licenses << l1
      track.licenses << l2

      expect(track.licenses.count).to eq(2)
      expect(track.cheapest_price).to eq("$10.00")
    end

    it "should return nil if there are no available licenses" do
      expect(track.cheapest_price).to be_nil
    end
  end

  describe "#available?" do
    it "should indicate that the track is available" do
      track = create(:track)

      expect(track.available?).to be(true)
    end

    it "should be unavailable if it's private" do
      track = create(:track, is_public: false)

      expect(track.available?).to be(false)
    end

    it "should be unavailable if it's discarded" do
      track = create(:track)
      track.discard!

      expect(track.available?).to be(false)
    end
  end

  describe "#undiscarded_comments" do
    it "should not return discarded comments" do
      track = create(:track)
      comment = create(:comment, entity: track)

      comment.discard!
      comment.reload
      track.reload

      expect(track.undiscarded_comments.count).to eq(0)
    end
  end

  describe "slugs" do
    subject(:track) { build(:track) }

    it "generates a slug if one does not exist when created" do
      track.title = "slug"
      track.save!

      expect(track.slug).to match(/^slug-[a-zA-Z0-9]{6}$/)
    end

    it "slug base is normalized" do
      track.title = "Lofi Chill Beat"
      track.save!

      expect(track.slug).to match(/^lofi_chill_beat-[a-zA-Z0-9]{6}$/)
    end

    it "should update slug if title changes" do
      track.save!
      old_slug = track.slug
      track.update!(title: "New")

      expect(track.slug).not_to eq(old_slug)
      expect(track.slug).to match(/^new-[a-zA-Z0-9]{6}$/)
    end
  end
end

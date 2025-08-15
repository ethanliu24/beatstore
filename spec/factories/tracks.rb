FactoryBot.define do
  factory :track do
    title { "Track 1" }
    key { "C MAJOR" }
    bpm { 111 }
    is_public { true }
    genre { "Trap" }

    after(:build) do |track|
      track.cover_photo.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "cover_photo.png")),
        filename: "cover_photo.png",
        content_type: "image/png"
      )
    end
  end

  factory :track_with_files, class: "Track" do
    title { "Track with files" }
    key { "C MAJOR" }
    bpm { 111 }
    is_public { true }
    genre { "Hip Hop" }

    after(:build) do |track|
      track.tagged_mp3.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "tagged_mp3.mp3")),
        filename: "tagged_mp3.mp3",
        content_type: "audio/mpeg"
      )
      track.untagged_mp3.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "untagged_mp3.mp3")),
        filename: "untagged_mp3.mp3",
        content_type: "audio/mpeg"
      )
      track.untagged_wav.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "untagged_wav.wav")),
        filename: "untagged_wav.wav",
        content_type: "audio/x-wav"
      )
      track.track_stems.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "track_stems.zip")),
        filename: "track_stems.zip",
        content_type: "application/zip"
      )
      track.project.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "project.zip")),
        filename: "project.zip",
        content_type: "application/zip"
      )
      track.cover_photo.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "cover_photo.png")),
        filename: "cover_photo.png",
        content_type: "image/png"
      )
    end
  end
end

FactoryBot.define do
  factory :track do
    title { "Track 1" }
    key { "C MAJOR" }
    bpm { 111 }
    is_public { true }
    genre { "Trap" }
  end

  factory :track_with_files, class: "Track" do
    title { "Track with files" }
    key { "C MAJOR" }
    bpm { 111 }
    is_public { true }
    genre { "Hip Hop" }

    after(:create) do |track|
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
        content_type: "audio/wav"
      )
      track.track_stems.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "tracks", "track_stems.zip")),
        filename: "track_stems.zip",
        content_type: "application/zip"
      )
    end
  end
end

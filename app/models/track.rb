# frozen_string_literal: true

class Track < ApplicationRecord
  include Discard::Model

  # before_validation :adjust_visibility
  before_validation { self.is_public = false if is_public.nil? }
  before_validation :generate_slug, on: :create
  before_validation :update_slug, if: :will_save_change_to_title?

  # === Constants ===
  VALID_KEYS = %w[C C# D D# Db E Eb F F# G G# Gb A A# Ab B Bb].freeze
  MAX_DESCRIPTION_LENGTH = 200
  GENRES = [ "Hip Hop", "Trap", "R&B", "Boom Bap", "New Jazz", "Plugnb" ].freeze
  SLUG_SEPERATOR = "-".freeze
  SLUG_SUFFIX_LENGTH = 6
  NO_PRICE_FORMAT = "N/A".freeze
  FILE_DELIVERY_RULES = {
    preview: ->(track) { track.preview.attached? },
    mp3: ->(track) { track.preview.attached? && track.untagged_mp3.attached? },
    wav: ->(track) { track.untagged_wav.attached? },
    stems: ->(track) { track.track_stems.attached? }
  }.freeze

  # === Validations ===
  validates :title, presence: true
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }, allow_blank: true
  validates :bpm, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :genre, presence: true, inclusion: { in: GENRES }
  validates :slug, presence: true, uniqueness: true
  validates :key, format: {
    with: /\A(#{VALID_KEYS.join('|')}) (MAJOR|MINOR)\z/,
    message: "must be a valid key, e.g. 'C MAJOR' or 'A# MINOR'"
  }, allow_blank: true

  validates :tagged_mp3, content_type: [ "audio/mpeg" ], if: -> { tagged_mp3.attached? }
  validates :untagged_mp3, content_type: [ "audio/mpeg" ], if: -> { untagged_mp3.attached? }
  validates :untagged_wav, content_type: [ "audio/x-wav", "audio/vnd.wave" ], if: -> { untagged_wav.attached? }
  validates :track_stems, content_type: [ "application/zip" ], if: -> { track_stems.attached? }
  validates :project, content_type: [ "application/zip" ], if: -> { project.attached? }
  validates :cover_photo, content_type: [ "image/png" ], if: -> { cover_photo.attached? }

  validate :shares_cannot_exceed_100_percent
  validate :license_selected_matches_available_files

  # === Relationships ===
  has_one_attached :tagged_mp3
  has_one_attached :untagged_mp3
  has_one_attached :untagged_wav
  has_one_attached :track_stems
  has_one_attached :project
  has_one_attached :cover_photo

  has_many :hearts, class_name: "Track::Heart"
  has_many :hearted_by_users, through: :hearts, source: :user
  has_many :plays, class_name: "Track::Play"
  has_many :tags, class_name: "Track::Tag", dependent: :destroy
  accepts_nested_attributes_for :tags, allow_destroy: true
  has_many :comments, as: :entity, dependent: :destroy
  has_many :collaborators, class_name: "Collaboration::Collaborator", as: :entity, dependent: :destroy
  accepts_nested_attributes_for :collaborators, allow_destroy: true, reject_if: :all_blank
  has_many :samples, class_name: "Collaboration::Sample", dependent: :destroy
  accepts_nested_attributes_for :samples, allow_destroy: true, reject_if: :all_blank
  has_many :licenses_tracks_associations, class_name: "Licenses::LicensesTracksAssociation", dependent: :destroy
  has_many :licenses, through: :licenses_tracks_associations
  has_many :cart_items, as: :product, dependent: :nullify
  has_many :free_downloads, dependent: :nullify

  # === Scopes ===
  scope :publicly_available, -> { kept.where(is_public: true) }

  class << self
    def ransackable_attributes(auth_object = nil)
      base = [
        "title",
        "description",
        "bpm",
        "key",
        "genre",
        "tags",
        "created_at",
        "updated_at"
      ]

      base << "is_public" if auth_object&.admin?
      base
    end

    def ransackable_associations(auth_object = nil)
      [ "tags" ]
    end
  end

  # def adjust_visibility
  #   # mark track private if not all links are available
  #   required_files = [ tagged_mp3, untagged_mp3, untagged_wav, track_stems, project ]
  #   self.is_public = !required_files.all?(&:blank?)
  # end

  # This is the id to use on track_path(id:). For user facing urls, we want a readable and
  # SEO friendly slug, so all track_path calls should pass in the id track_path(id: track.slug_param)
  # instead of the original bigint id.
  #
  # The last part of the slug_param should always be the original bigint id, so extraction from urls
  # would always work on both slug and bigint ids.
  def slug_param
    "#{slug}#{SLUG_SEPERATOR}#{id}"
  end

  def preview
    tagged_mp3
  end

  def is_public?
    is_public
  end

  def num_plays
    plays.count
  end

  def num_hearts
    hearts.count
  end

  def profitable_licenses
    undiscarded_licenses
      .where
      .not(contract_type: License.contract_types[:free])
      .order(:price_cents)
      .select do |l|
        contract = l.contract

        # Only keep licenses whose deliverables match actual attached files
        (!contract[:delivers_mp3] || FILE_DELIVERY_RULES[:mp3].call(self)) &&
        (!contract[:delivers_wav] || FILE_DELIVERY_RULES[:wav].call(self)) &&
        (!contract[:delivers_stems] || FILE_DELIVERY_RULES[:stems].call(self))
      end
  end

  def cheapest_price
    profitable_licenses.first&.price&.format.presence || NO_PRICE_FORMAT
  end

  def available?
    is_public && kept? && preview.attached?
  end

  def undiscarded_comments
    comments.kept
  end

  def undiscarded_licenses
    licenses.kept
  end

  private

  def shares_cannot_exceed_100_percent
    total_profit = collaborators.sum { |c| c.profit_share.to_d }
    total_publishing = collaborators.sum { |c| c.profit_share.to_d }
    if total_profit > 100 || total_publishing > 100
      errors.add(:base, I18n.t("admin.track.error.invalid_share_sum"))
    end
  end

  def license_selected_matches_available_files
    required_deliverables = licenses.each_with_object(Set.new) do |license, required|
      contract = license.contract

      required << :preview if license.contract_type == License.contract_types[:free]
      required << :mp3 if contract[:delivers_mp3] && license.contract_type != License.contract_types[:free]
      required << :wav if contract[:delivers_wav]
      required << :stems if contract[:delivers_stems]
    end

    missing = required_deliverables.reject do |type|
      FILE_DELIVERY_RULES[type].call(self)
    end

    unless missing.empty?
      errors.add(:base, I18n.t("admin.track.error.unmatching_license_file_delivered", required_files: missing))
    end
  end

  def generate_slug
    base = title.to_s.downcase.parameterize(separator: "_")
    loop do
      suffix = SecureRandom.alphanumeric(SLUG_SUFFIX_LENGTH)
      slug = "#{base}#{SLUG_SEPERATOR}#{suffix}"
      break self.slug = slug unless Track.exists?(slug:)
    end
  end

  def update_slug
    base = title.to_s.downcase.parameterize(separator: "_")
    suffix = slug.split(SLUG_SEPERATOR).last
    self.slug = "#{base}#{SLUG_SEPERATOR}#{suffix}"
  end
end

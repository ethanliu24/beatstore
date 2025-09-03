# frozen_string_literal: true

class Track < ApplicationRecord
  # before_validation :adjust_visibility
  before_validation { self.is_public = false if is_public.nil? }

  # === Constants ===
  VALID_KEYS = %w[C C# D D# Db E Eb F F# G G# Gb A A# Ab B Bb].freeze
  MAX_DESCRIPTION_LENGTH = 200
  GENRES = [ "Hip Hop", "Trap", "R&B", "Boom Bap", "New Jazz", "Plugnb" ].freeze

  # === Validations ===
  validates :title, presence: true
  validates :description, length: { maximum: MAX_DESCRIPTION_LENGTH }, allow_blank: true
  validates :bpm, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :genre, presence: true, inclusion: { in: GENRES }
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
    licenses.where.not(contract_type: License.contract_types[:free]).order(:price_cents)
  end

  def cheapest_price
    profitable_licenses.first&.price&.format.presence
  end

  private

  def shares_cannot_exceed_100_percent
    total_profit = collaborators.sum { |c| c.profit_share.to_d }
    total_publishing = collaborators.sum { |c| c.profit_share.to_d }
    if total_profit > 100 || total_publishing > 100
      errors.add(:base, I18n.t("admin.track.error.invalid_share_sum"))
    end
  end
end

# frozen_string_literal: true

require "ostruct"

module ApplicationHelper
  include Pagy::Frontend
  include ActionView::Helpers::DateHelper

  def title(input = nil)
    content_for(:title) { "#{input}" } if input
  end

  def format_date(date)
    date.strftime("%b. %-d, %Y")
  end

  def times_ago(time)
    diff = Time.current - time

    if diff < 1.minute
      t("general.just_now")
    else
      "#{time_ago_in_words(time).gsub(/^about /, "")} #{t("general.times_ago")}"
    end
  end

  def snake_case(s)
    s.downcase.split(" ").join("_")
  end

  def seperator_char_ui(class: "", data: {})
    content_tag(:span, "·", class:, data:)
  end

  def currencies
    ISO3166::Country.all.map { |c| c.currency_code }.compact.uniq.sort
  end
end

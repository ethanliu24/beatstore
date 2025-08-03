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
      "#{time_ago_in_words(time)} #{t("general.times_ago")}"
    end
  end

  def snake_case(s)
    s.downcase.split(" ").join("_")
  end

  def seperator_char_ui(class: "")
    content_tag(:span, "·", class:)
  end
end

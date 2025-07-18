module ApplicationHelper
  include Pagy::Frontend

  def title(input = nil)
    content_for(:title) { "#{input}" } if input
  end

  def format_date(date)
    date.strftime("%b. %-d, %Y")
  end

  def snake_case(s)
    s.downcase.split(" ").join("_")
  end
end

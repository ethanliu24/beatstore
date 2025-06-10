module ApplicationHelper
  def title(input = nil)
    content_for(:title) { "#{input}" } if input
  end

  def format_date(date)
    date.strftime("%b. %-d, %Y")
  end
end

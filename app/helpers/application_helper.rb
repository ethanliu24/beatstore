module ApplicationHelper
  def title(input = nil)
    content_for(:title) { "#{input}" } if input
  end
end

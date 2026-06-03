# frozen_string_literal: true

module OrderHelper
  def product_status_color(status)
    case status
    when Order.statuses[:completed]
      "text-success"
    when Order.statuses[:failed], Order.statuses[:canceled]
      "text-error"
    else
      ""
    end
  end
end

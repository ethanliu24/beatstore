module OrderHelper
  def status_color(status)
    case status
    when Order.statuses[:completed]
      "text-success"
    when Order.statuses[:failed]
      "text-error"
    else
      ""
    end
  end
end

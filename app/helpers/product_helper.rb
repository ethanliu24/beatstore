module ProductHelper
  def product_name(order_item)
    case order_item.product_type
    when Track.name
      order_item.product_snapshot["title"]
    else
      ""
    end
  end

  def product_info_ui(order_item)
    product = order_item.product_snapshot

    content_tag(:div, class: "flex justify-start items-center text-[0.6rem] text-secondary-txt gap-1 w-full truncate") do
      parts = []

      case order_item.product_type
      when Track.name
        if product["bpm"].present?
          parts << content_tag(:p, "#{product["bpm"]} BPM")
          parts << seperator_char_ui
        end

        if product["key"].present?
          parts << content_tag(:p, product["key"])
          parts << seperator_char_ui
        end

        parts << content_tag(:p, product["genre"])

        safe_join(parts)
      else
        ""
      end
    end
  end
end

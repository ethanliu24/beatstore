module CartHelper
  def cart_item_has_photo?(cart_item)
    case cart_item.product_type
    when Track.name
      cart_item.product.cover_photo.attached?
    else
      nil
    end
  end

  def cart_item_photo_url(cart_item)
    product = cart_item.product

    case cart_item.product_type
    when Track.name
      product.cover_photo.attached? ? url_for(product.cover_photo) : nil
    else
      nil
    end
  end

  def cart_item_product_title(cart_item)
    case cart_item.product_type
    when Track.name
      track = cart_item.product
      link_to(track.title, track_path(track))
    else
      ""
    end
  end
end

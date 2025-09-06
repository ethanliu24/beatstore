module CartHelper
  def cart_total_price(cart)
    price_cents = cart.nil? ? 0 : cart.total_price_cents
    # Cart should have a currency, but everything's USD in this case
    Money.new(price_cents, "USD").format
  end

  def cart_item_has_photo?(cart_item)
    return unless cart_item.available?

    case cart_item.product_type
    when Track.name
      cart_item.product.cover_photo.attached?
    else
      nil
    end
  end

  def cart_item_photo_url(cart_item)
    return unless cart_item.available?

    product = cart_item.product

    case cart_item.product_type
    when Track.name
      product.cover_photo.attached? ? url_for(product.cover_photo) : nil
    else
      nil
    end
  end

  def cart_item_product_title(cart_item)
    return unless cart_item.available?

    case cart_item.product_type
    when Track.name
      track = cart_item.product
      link_to(track.title, track_path(track))
    else
      ""
    end
  end

  def cart_item_track_files_delivered(cart_item)
    return unless cart_item.available?
    return nil unless cart_item.product_type == Track.name

    files = []
    contract = cart_item.license.contract
    files << "mp3" if contract[:delivers_mp3]
    files << "wav" if contract[:delivers_wav] || contract[:delivers_stems]

    files.join(", ")
  end
end

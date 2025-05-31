module ImageHelper
  def has_img_attached?
    @track.cover_photo.attached?
  end

  def track_image_url
    if has_img_attached?
      url_for(@track.cover_photo)
    else
      nil
    end
  end
end

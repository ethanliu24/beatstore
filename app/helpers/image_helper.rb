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

  def user_pfp_url
    if current_user && current_user.profile_picture.attached?
      url_for(current_user.profile_picture)
    else
      nil
    end
  end
end

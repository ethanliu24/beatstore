module UserHelper
  def max_user_bio_length
    User::BIOGRAPHY_LENGTH
  end

  def max_display_name_length
    User::DISPLAY_NAME_LENGTH
  end
end

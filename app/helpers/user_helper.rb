module UserHelper
  def max_user_bio_length
    User::BIOGRAPHY_LENGTH
  end

  def max_display_name_length
    User::DISPLAY_NAME_LENGTH
  end

  def default_avatar_icon(size)
    icon_size = "w-#{size} h-#{size}"

    <<~SVG.html_safe
      <svg class="absolute text-gray-400 translate-y-1 #{icon_size}"
        fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
          clip-rule="evenodd"></path>
      </svg>
    SVG
  end
end

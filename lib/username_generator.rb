module UsernameGenerator
  def generate_unique_username(email)
    base = email.to_s.split("@").first.downcase.gsub(/[^a-z0-9]/, "_")
    base = "user" if base.blank?

    username = base
    suffix = 1

    while User.exists?(username: username)
      suffix += 1
      username = "#{base}#{suffix}"
    end

    username
  end

  module_function :generate_unique_username
end

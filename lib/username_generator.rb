module UsernameGenerator
  def generate_from_email(email)
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

  module_function :generate_from_email
end

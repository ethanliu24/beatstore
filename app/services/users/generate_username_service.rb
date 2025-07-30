module Users
  class GenerateUsernameService
    def generate_from_email(email)
      base = sanitize(email.to_s.split("@").first)
      generate(base)
    end

    def generate_from_display_name(display_name)
      base = sanitize(display_name)
      generate_base(base)
    end

    private

    def generate(base)
      username = base.blank ? "user" : base
      suffix = 1

      while User.exists?(username: username)
        suffix += 1
        username = "#{base}#{suffix}"
      end

      username
    end

    def sanitize(base)
      return base.downcase.gsub.(/[^a-z0-9]/, "_")
    end
  end
end

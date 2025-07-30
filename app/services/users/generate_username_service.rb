module Users
  class GenerateUsernameService
    def generate_from_email(email)
      base = sanitize(email.to_s.split("@").first)
      generate(base)
    end

    def generate_from_display_name(display_name)
      base = sanitize(display_name)
      generate(base)
    end

    private

    def generate(base)
      username = base.empty? ? "user" : base
      suffix = 1

      while User.exists?(username: username)
        suffix += 1
        username = "#{base}#{suffix}"
      end

      username
    end

    def sanitize(base)
      if base
        base.downcase.gsub(/[^a-z0-9]/, "_")
      else
        ""
      end
    end
  end
end

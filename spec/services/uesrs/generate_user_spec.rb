require "rails_helper"

RSpec.describe Users::GenerateUsernameService, type: :service do
  before do
    @service = Users::GenerateUsernameService.new
  end

  context "#generate_from_display_name" do
    it "should generate a username if there are no duplicated name after sanitization" do
      display_name = "abcd"
      result = @service.generate_from_display_name(display_name)

      expect(result).to eq("abcd")
    end

    it "should increment username suffix if it exists" do
      user = create(:user)
      display_name = user.username
      expected = "#{display_name}2"
      result = @service.generate_from_display_name(display_name)

      expect(result).to eq(expected)
    end

    it "should base username as 'user' if display name is empty" do
      display_name = ""
      result = @service.generate_from_display_name(display_name)

      expect(result).to eq("user")
    end

    it "should replace all non alphanumeric characters with an underscore and lowercase them" do
      display_name = "A_b-c D.1234"
      result = @service.generate_from_display_name(display_name)

      expect(result).to eq("a_b_c_d_1234")
    end
  end

  context "#generate_from_email" do
    it "should generate a username with the part before '@' if there are no duplicated name after sanitization" do
      email = "email@example.com"
      result = @service.generate_from_email(email)

      expect(result).to eq("email")
    end

    it "should increment username suffix if it exists" do
      user = create(:user)
      email = user.username
      expected = "#{email}2"
      result = @service.generate_from_email(email)

      expect(result).to eq(expected)
    end

    it "should base username as 'user' if display name is empty" do
      email = ""
      result = @service.generate_from_email(email)

      expect(result).to eq("user")
    end

    it "should base username as 'user' if there's nothing before '@'" do
      email = "@example.com"
      result = @service.generate_from_email(email)

      expect(result).to eq("user")
    end

    it "should replace all non alphanumeric characters with an underscore and lowercase them" do
      email = "A_b-c+D.1234@email.com"
      result = @service.generate_from_email(email)

      expect(result).to eq("a_b_c_d_1234")
    end
  end
end

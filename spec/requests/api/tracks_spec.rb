require 'rails_helper'

RSpec.describe "Api::Tracks", type: :request do
  describe "GET /show" do
    it "gets track data" do
      # Might need to configure ActiveStorage::Current url options for rspec
      # RSpec.configure do |config|
      #   ActiveStorage::Current.url_options = {host: "https://www.example.com"}
      # end
      pending "attach object files to test for #{__FILE__}"
    end
  end
end

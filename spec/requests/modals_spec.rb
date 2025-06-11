require 'rails_helper'

RSpec.describe "Modals", type: :request do
  describe "where requests are from users" do
    it "does not allow visits to #test" do
      get test_modal_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "where request are from turbo frame" do
    before do
      @headers = { "Turbo-Frame" => "modal" }
    end

    it "fetches modal from #test" do
      get test_modal_path, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modal/_test")
    end
  end
end

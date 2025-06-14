require 'rails_helper'

RSpec.describe "Modals", type: :request do
  describe "where requests are from users" do
    it "does not allow visits to #track_image_upload" do
      get track_image_upload_modal_url
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #auth_promp" do
      get auth_prompt_modal_url
      expect(response).to redirect_to(root_path)
    end
  end

  describe "where request are from turbo frame" do
    before do
      @headers = { "Turbo-Frame" => "modal" }
    end

    it "fetches modal from #track_image_upload" do
      get track_image_upload_modal_url, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_image_upload")
    end

    it "fetches modal from #auth_prompt" do
      get auth_prompt_modal_url, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_auth_prompt")
    end
  end
end

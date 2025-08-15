require 'rails_helper'

RSpec.describe ModalsController, type: :request do
  describe "where requests are from users" do
    it "does not allow visits to #track_image_upload" do
      get track_image_upload_modal_url
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #user_pfp_upload" do
      get user_pfp_upload_modal_url
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #auth_promp" do
      get auth_prompt_modal_url
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #delete_account" do
      get delete_account_modal_url
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #delete_comment" do
      user = create(:user)
      track = create(:track)
      comment = create(:comment, entity: track, user:)
      get delete_comment_modal_url(comment)
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #track_more_info" do
      track = create(:track)
      get track_more_info_modal_url(track)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "where request are from turbo frame" do
    it "fetches modal from #track_image_upload" do
      get track_image_upload_modal_url(format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_image_upload")
    end

    it "fetches modal from #track_image_upload" do
      get user_pfp_upload_modal_url(format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_image_upload")
    end

    it "fetches modal from #auth_prompt" do
      get auth_prompt_modal_url(format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_auth_prompt")
    end

    it "fetches modal from #delete_account" do
      get delete_account_modal_url(format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_delete_account")
    end

    it "fetches modal from #delete_comment" do
      user = create(:user)
      track = create(:track)
      comment = create(:comment, entity: track, user:)

      get delete_comment_modal_url(comment, format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_delete_comment")
    end

    it "fetches modal from #track_more_info" do
      track = create(:track)

      get track_more_info_modal_url(track, format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_track_more_info")
    end
  end
end

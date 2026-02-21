require 'rails_helper'

RSpec.describe ModalsController, type: :request do
  describe "where requests are from users" do
    it "does not allow visits to #image_upload" do
      get image_upload_modal_url
      expect(response).to redirect_to(root_path)
    end

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

    it "does not allow visits to #preview_contract" do
      license = create(:license)
      get preview_contract_modal_url(license_id: license.id)
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #free_download" do
      track = create(:track)
      get free_download_modal_url(track)
      expect(response).to redirect_to(root_path)
    end

    it "does not allow visits to #delete_account" do
      get clear_cart_modal_url
      expect(response).to redirect_to(root_path)
    end
  end

  describe "where request are from turbo frame" do
    it "fetches modal from #image_upload" do
      get image_upload_modal_url(
        format: :turbo_stream,
        model_field: "model[image]",
        img_destination_id: "abc",
        file_upload_input_container_id: "456"
      ), headers: @headers

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_image_upload")
    end

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

    it "fetches modal from #track_more_info" do
      track = create(:track)
      license = create(:license, contract_details: { document_template: License.track_contract_templates[:free] })

      get preview_contract_modal_url(license_id: license.id, track_id: track.id, format: :turbo_stream), headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(partial: "modals/_preview_contract")
    end

    describe "#preview_contract" do
      let!(:track) { create(:track) }
      let!(:license) { create(
        :license,
        contract_details: {
          "document_template" => Rails.configuration.templates[:contracts][License.contract_types[:free]]
        }
      )}

      context "render with license_id" do
        it "should render the default template if license_id not available" do
          get preview_contract_modal_url(
            license_id: License.count + 1,
            entity_type: Track.name,
            contract_type: License.contract_types[:free],
            format: :turbo_stream
          )

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("{{ LICENSE_NAME }}")
        end

        it "should render the document contract defined in license if license_id is valid" do
          license.update!(contract_details: { document_template: "123" })

          get preview_contract_modal_url(license_id: license.id, track_id: track.id, format: :turbo_stream)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("123")
        end
      end

      context "render with order_item_id" do
        let!(:user) { create(:user) }
        let!(:order) { create(:order, user:) }
        let!(:transaction) { create(:payment_transaction, order:, customer_name: "LeBron James") }
        let!(:order_item) {
          create(
            :order_item,
            order:,
            product_snapshot: Snapshots::TakeTrackSnapshotService.new(track:).call,
            license_snapshot: Snapshots::TakeLicenseSnapshotService.new(license:).call
          )
        }

        before do
          sign_in user, scope: :user
        end

        it "should allow the user that purchased the product view contract" do
          get preview_contract_modal_url(order_item_id: order_item.id, format: :turbo_stream)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("<strong>LeBron James</strong>")
        end

        it "should let admin see what the user purchased" do
          admin = create(:admin)
          sign_in admin, scope: :user
          get preview_contract_modal_url(order_item_id: order_item.id, format: :turbo_stream)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("<strong>LeBron James</strong>")
        end

        it "should not let unrelated person see the contract" do
          other_user = create(:guest)
          sign_in other_user, scope: :user
          get preview_contract_modal_url(order_item_id: order_item.id, format: :turbo_stream)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#free_download" do
      it "fetches modal if there are free contracts" do
        track = create(:track)
        free_license = create(:license, contract_type: License.contract_types[:free])
        track.licenses << free_license

        get free_download_modal_url(track, format: :turbo_stream), headers: @headers
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(partial: "modals/_free_download")
      end

      it "fetches modal if there are no free contracts" do
        track = create(:track)
        license = create(:license, contract_type: License.contract_types[:non_exclusive])
        track.licenses << license

        get free_download_modal_url(track, format: :turbo_stream), headers: @headers
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(partial: "modals/_free_download")
      end

      it "fetches modal if there are no contracts at all" do
        track = create(:track)

        get free_download_modal_url(track, format: :turbo_stream), headers: @headers
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(partial: "modals/_free_download")
      end
    end
  end

  it "fetches modal from #delete_account" do
    get clear_cart_modal_url(format: :turbo_stream), headers: @headers
    expect(response).to have_http_status(:ok)
    expect(response).to render_template(partial: "modals/_clear_cart")
  end
end

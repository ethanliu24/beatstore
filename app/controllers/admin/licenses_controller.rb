# frozen_string_literal: true

module Admin
  class LicensesController < Admin::BaseController
    before_action :resolve_contract_class, only: [ :create, :update ]

    def index
      @licenses = License.order(updated_at: :desc)
    end

    def new
      @license = License.new
      @contract_type = params[:contract_type]

      unless License.contract_types.key?(@contract_type.to_s)
        @contract_type = nil
      end
    end

    def create
      if @contract_class.nil?
        render :new, status: :unprocessable_content
        return
      end

      @license = License.new(sanitize_license_params)
      @contract = @contract_class.new(**@license.contract)
      process_license
    end

    def update
    end

    private

    def resolve_contract_class
      if params[:license].nil?
        @contract_class = nil
        return
      end

      case params[:license][:contract_type]
      when License.contract_types[:free]
        @contract_class = Contracts::Track::Free
      when License.contract_types[:non_exclusive]
        @contract_class = Contracts::Track::NonExclusive
      else
        @contract_class = nil
      end
    end

    def sanitize_license_params
      permitted = params.require(:license).permit(
        :title,
        :description,
        :contract_type,
        :price_cents,
        :currency,
        :country,
        :province,
        :default_for_new,
        contract_details: @contract_class.attribute_types.keys,
      )

      if permitted[:price_cents].present?
        permitted[:price_cents] = (permitted[:price_cents].to_f * 100).round
      end

      permitted
    end

    def process_license
      if @contract.valid? && @license.save
        redirect_to admin_licenses_path, notice: t("admin.license.create.sucess")
      else
        @contract.errors.each do |error|
          @license.errors.add(error.attribute, error.message)
        end

        @contract_type = params[:license][:contract_type]
        render action_name == "create" ? :new : :edit, status: :unprocessable_content
      end
    end
  end
end

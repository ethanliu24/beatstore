# frozen_string_literal: true

module Admin
  class LicensesController < Admin::BaseController
    before_action :set_license, only: [ :edit, :update, :destroy, :apply_to_all, :remove_from_all ]

    def index
      @licenses = License.kept.order(updated_at: :desc)
    end

    def new
      @license = License.new
      @contract_type = params[:contract_type]

      unless License.contract_types.key?(@contract_type.to_s)
        @contract_type = nil
      end
    end

    def create
      if params[:license].nil?
        render :new, status: :unprocessable_content
        return
      end

      @contract_class = resolve_contract_type(params[:license][:contract_type])
      @license = License.new(sanitize_license_params)
      @contract = @contract_class.new(**@license.contract)

      if @contract.valid?
        @license.contract_details = @contract.attributes

        if @license.save
          redirect_to admin_licenses_path, notice: t("admin.license.create.success")
          return
        end
      end

      handle_create_or_update_errors
      render :new, status: :unprocessable_content
    end

    def edit
      @contract_type = @license.contract_type
    end

    def update
      @contract_class = resolve_contract_type(@license.contract_type)
      update_params = sanitize_license_params
      @contract = @contract_class.new(**update_params[:contract_details])

      if @contract.valid?
        update_params[:contract_details] = @contract.attributes

        if @license.update(update_params)
          redirect_to admin_licenses_path, notice: t("admin.license.update.success")
          return
        end
      end

      handle_create_or_update_errors
      render :edit, status: :unprocessable_content
    end

    def destroy
      @license.discard!

      redirect_to admin_licenses_path, status: :see_other, notice: t("admin.license.destroy.success")
    end

    def apply_to_all
      entity = resolve_contract_type_corresponding_entity(@license.contract_type)
      return if entity.nil?

      entity.all.each do |e|
        e.licenses << @license unless e.licenses.include?(@license)
      end

      respond_to do |format|
        flash.now[:notice] = t("admin.license.apply_to_all.success")
        format.turbo_stream { render turbo_stream: turbo_stream.update("toasts", partial: "shared/toasts") }
      end
    end

    def remove_from_all
      entity = resolve_contract_type_corresponding_entity(@license.contract_type)
      return if entity.nil?

      entity.all.each do |e|
        e.licenses.delete(@license)
      end

      respond_to do |format|
        flash.now[:notice] = t("admin.license.remove_from_all.success")
        format.turbo_stream { render turbo_stream: turbo_stream.update("toasts", partial: "shared/toasts") }
      end
    end

    private

    def resolve_contract_type(contract_type)
      return nil if contract_type.nil?

      case contract_type
      when License.contract_types[:free]
        Contracts::Track::Free
      when License.contract_types[:non_exclusive]
        Contracts::Track::NonExclusive
      else
        nil
      end
    end

    def resolve_contract_type_corresponding_entity(contract_type)
      if [
        License.contract_types[:free],
        License.contract_types[:non_exclusive]
      ].include?(contract_type)
        Track
      else
        nil
      end
    end

    def set_license
      @license = License.kept.find(params[:id])
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
        permitted[:price_cents] = (permitted[:price_cents].to_d * 100).to_i
      end

      permitted
    end

    def handle_create_or_update_errors
      @contract.errors.each do |error|
        @license.errors.add(error.attribute, error.message)
      end

      @contract_type = params[:license][:contract_type]
    end
  end
end

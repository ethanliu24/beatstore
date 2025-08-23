# frozen_string_literal: true

module Admin
  class LicensesController < Admin::BaseController
    def new
      @contract_form = get_contract_form
      @license = License.new
    end

    private

    def get_contract_form
      case params[:contract_type]
      when License.contract_types[:free]
        "contracts/tracks/free"
      when License.contract_types[:non_exclusive]
        "contracts/tracks/non_exclusive"
      else
        # TODO redirect to 404
        ""
      end
    end
  end
end

module Admin
  class BaseController < ApplicationController
    before_action :is_admin?

    def is_admin?
      redirect_to root_path, alert: t("authentication.not_authorized_message") unless current_user&.admin?
    end
  end
end

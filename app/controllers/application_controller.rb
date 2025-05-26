class ApplicationController < ActionController::Base
  before_action :store_previous_location, if: :storable_location?

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  private

  def storable_location?
    request.get? &&
    is_navigational_format? &&
    !devise_controller? &&
    !request.xhr? &&
    !user_signed_in?
  end

  def store_previous_location
    store_location_for(:user, request.fullpath)
  end
end

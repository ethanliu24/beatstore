class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :store_previous_location, if: :storable_location?

  helper_method :current_or_guest_user

  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in
        guest_user(with_retry = false).try(:reload).try(:destroy)
        session[:guest_user_id] = nil
      end

      current_user
    else
      guest_user
    end
  end

  def guest_user(with_retry = true)
    session[:guest_user_id] ||= create_guest_user.id
    @cached_guest_user ||= User.find(session[:guest_user_id])
  rescue ActiveRecord::RecordNotFound
     session[:guest_user_id] = nil
     guest_user if with_retry
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource)
    root_path
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

  def turbo_or_xhr_request?
    turbo_frame_request? || request.xhr? || request.format.turbo_stream?
  end

  def logging_in
    # TODO transfer guest cart to user carts AND append to #create in session and registration
  end

  def create_guest_user
    name = Users::GenerateUsernameService.new.generate_from_display_name("guest")
    pw = SecureRandom.hex(16)
    guest = User.new(
      username: name,
      display_name: name,
      role: User.roles[:guest],
      email: "#{name}@example.com",
      password: pw,
      password_confirmation: pw,
      confirmed_at: Time.now
    )

    guest.save!(validate: false)
    session[:guest_user_id] = guest.id

    guest
  end
end

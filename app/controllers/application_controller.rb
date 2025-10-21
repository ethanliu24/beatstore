class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :store_previous_location, if: :storable_location?

  helper_method :current_or_guest_user

  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        transfer_guest_to_user
        guest = guest_user(with_retry = false)
        guest.cart.destroy!
        guest.try(:reload).try(:destroy)
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

  def transfer_guest_to_user
    return if guest_user.nil?

    # DB Transaction guard so that if one action fails, all fails
    ActiveRecord::Base.transaction do
      guest_user.cart.cart_items.find_each do |item|
        existing = current_user.cart.cart_items.find_by(
          product_type: item.product_type,
          product_id: item.product_id,
          license_id: item.license_id
        )

        # TODO should increment quantity for items that should be incremented.
        # Track or Kit should not be incremented.
        unless existing
          item.update!(cart_id: current_user.cart.id)
        end
      end

      guest_user.orders.update_all(user_id: current_user.id)
    end
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

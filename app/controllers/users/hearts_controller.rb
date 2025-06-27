class Users::HeartsController < ApplicationController
  before_action :authenticate_user!

  def index; end
end

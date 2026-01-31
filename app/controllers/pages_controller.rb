class PagesController < ApplicationController
  def home
    @q = Track.ransack()
  end
end

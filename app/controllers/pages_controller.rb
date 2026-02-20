class PagesController < ApplicationController
  def home
    @q = Track.ransack

    @test_tracks = Track.all
  end
end

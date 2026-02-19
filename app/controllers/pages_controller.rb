class PagesController < ApplicationController
  def home
    @q = Track.ransack

    @test_tracks = Track.all.limit(4)
  end
end

class ModalsController < ApplicationController
  def test
    @track = Track.first
    render partial: "modal/test", locals: { track: @track }
  end
end

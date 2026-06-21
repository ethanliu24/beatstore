# frozen_string_literal: true

module Admin
  class MetricsController < Admin::BaseController
    CHART_REFRESH_SECONDS = 60

    before_action :set_window

    def index; end

    def dashboards
      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def set_window
      @window = params[:window] || WindowSize::ONE_DAY
    end
  end
end

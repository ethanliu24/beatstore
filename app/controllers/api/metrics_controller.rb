# frozen_string_literal: true

# https://chartkick.com/
class Api::MetricsController < ApplicationController
  before_action :return_if_not_admin
  before_action :set_window

  def stripe_checkout_intent
    render json: line_chart_metrics(Metrics::Name::STRIPE_CHECKOUT_INTENT)
  end

  def stripe_one_time_payment
    render json: line_chart_metrics(Metrics::Name::STRIPE_ONE_TIME_PAYMENT)
  end

  private

  def line_chart_metrics(event_name, tags: {}, &tag_filter)
    relation = Metric
      .where(event_name:)
      .where(created_at: BuildTimeFrameWindowService.time_frame(@window)..Time.current)
      .where("tags @> ?", tags.to_json)

    if tag_filter
      ids = relation.select { |record| tag_filter.call(record.tags) }.map(&:id)
      relation = Metric.where(id: ids)
    end

    metrics = BuildTimeFrameWindowService.group_metrics_by_time(
      relation,
      window: @window,
      column: :created_at
    )

    metrics.count
  end

  def set_window
    @window = params.require(:window)
  end

  def return_if_not_admin
    unless current_user&.admin?
      head :not_found and return
    end
  end
end

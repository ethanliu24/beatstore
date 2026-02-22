# frozen_string_literal: true

require "json"

module Admin
  class RecommendationsController < Admin::BaseController
    def index
      @recommendations = TrackRecommendation.rank(:display_order).all
    end

    def new
      @recommendation = TrackRecommendation.new
      @tags = get_tags(recommendation: @recommendation)
    end

    def create
      @recommendation = TrackRecommendation.new(
        sanitize_recommendation_params.merge(display_order_position: :first)
      )

      unless @recommendation.save
        @tags = get_tags(recommendation: @recommendation)
        render :new, status: :unprocessable_content
        return
      end

      redirect_to admin_recommendations_path, notice: t("admin.recommendations.create.success")
    end

    def edit
      @recommendation = TrackRecommendation.find(params[:id])
      @tags = get_tags(recommendation: @recommendation)
    end

    def update
      @recommendation = TrackRecommendation.find(params[:id])

      unless @recommendation.update(sanitize_recommendation_params)
        @tags = get_tags(recommendation: @recommendation)
        render :new, status: :unprocessable_content
        return
      end

      redirect_to admin_recommendations_path, notice: t("admin.recommendations.update.success")
    end

    def destroy
      @recommendation = TrackRecommendation.find(params[:id])
      @recommendation.destroy!

      redirect_to admin_recommendations_path, status: :see_other, notice: t("admin.recommendations.destroy.success")
    end

    def reorder
      ordering = params.require(:track_recommendation).permit(:ordering).presence || []

      # Can bulk update, but not neccessary for now
      # cases = ordering.map.with_index { |id, idx| "WHEN #{id.to_i} THEN #{idx}" }.join(" ")
      #
      # sql = <<~SQL
      # UPDATE track_recommendations
      # SET display_order_position = CASE id
      #   #{cases}
      # END
      # WHERE id IN (#{ordering.join(",")});
      # SQL

      ordering.each_with_index do |id, index|
        TrackRecommendation.find(id).update(display_order_position: index)
      end
    end

    private

    def sanitize_recommendation_params
      permitted = params.require(:track_recommendation).permit(
        :group,
        :tag_names,
        :display_image,
      )

      if permitted[:tag_names].present? && !permitted[:tag_names].is_a?(Array)
        permitted[:tag_names] = JSON.parse(permitted[:tag_names].to_s)
      end

      permitted
    end

    def get_tags(recommendation:)
      selected = recommendation.tag_names.to_set
      all_tags = Track::Tag.names

      all_tags
        .map { |t| { name: t, selected: selected.include?(t) } }
        .sort_by { |t| t[:selected] ? 0 : 1 }
    end
  end
end

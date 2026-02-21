# frozen_string_literal: true

require "json"

module Admin
  class RecommendationsController < Admin::BaseController
    def index
    end

    def new
      @recommendation = TrackRecommendation.new
      @tags = get_tags(recommendation: @recommendation)
    end

    def create
      @recommendation = TrackRecommendation.new(sanitize_recommendation_params)

      if @recommendation.save
        redirect_to admin_recommendations_path, notice: t("admin.recommendations.create.success")
        return
      end

      @tags = get_tags(recommendation: @recommendation)
      render :new, status: :unprocessable_content
    end

    def edit
    end

    def update
    end

    def destroy
    end

    private

    def sanitize_recommendation_params
      permitted = params.require(:track_recommendation).permit(
        :group,
        :tag_names,
        :display_image,
      )

      if permitted[:tag_names].present?
        permitted[:tag_names] = JSON.parse(permitted[:tag_names])
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

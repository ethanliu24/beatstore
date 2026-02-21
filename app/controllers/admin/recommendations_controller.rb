# frozen_string_literal: true

module Admin
  class RecommendationsController < Admin::BaseController
    def index
    end

    def new
      @recommendation = TrackRecommendation.new
      @tags = get_tags(recommendation: @recommendation)
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
    end

    private

    def get_tags(recommendation:)
      selected = recommendation.tag_names.to_set
      all_tags = Track::Tag.names

      all_tags
        .map { |t| { name: t, selected: selected.include?(t) } }
        .sort_by { |t| t[:selected] ? 0 : 1 }
    end
  end
end

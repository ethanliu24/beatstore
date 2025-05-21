require "rails_helper"

RSpec.describe TracksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tracks").to route_to("tracks#index")
    end

    it "routes to #show" do
      expect(get: "/tracks/1").to route_to("tracks#show", id: "1")
    end
  end
end

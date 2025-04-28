# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::RatingTypeController do
  let!(:create_params) { { type: "comfort", name: "Comfort" } }
  let!(:update_params) { { type: "comfort", name: "Comfort Zone" } }
  fab!(:admin) { sign_in(Fabricate(:admin)) }

  describe "#create" do
    it "creates the rating type correctly" do
      post "/ratings/rating-type.json", params: create_params
      expect(response.status).to eq(200)
      expect(DiscourseRatings::RatingType.all.map { |t| t.type }).to include(create_params[:type])
    end
  end

  describe "#update" do
    it "updates the rating type correctly" do
      DiscourseRatings::RatingType.create(create_params[:type], create_params[:name])
      put "/ratings/rating-type/" + update_params[:type] + ".json", params: update_params
      expect(response.status).to eq(200)
      expect(DiscourseRatings::RatingType.get_name(create_params[:type])).to eq(
        update_params[:name],
      )
    end
  end
end

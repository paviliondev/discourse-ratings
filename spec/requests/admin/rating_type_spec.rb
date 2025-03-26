# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::RatingTypeController do
  let!(:create_params) { { type: "comfort", name: "Comfort" } }
  let!(:update_params) { { type: "comfort", name: "Comfort Zone" } }
  let!(:delete_params) { { type: "comfort" } }
  fab!(:admin) { sign_in(Fabricate(:admin)) }

  describe "#index" do
    it "displays the rating type correctly" do
      DiscourseRatings::RatingType.create(
        create_params[:type],
        create_params[:name]
      )
      get "/ratings/rating-type.json"
      expect(response.status).to eq(200)
    end
  end
  describe "#create" do
    it "creates the rating type correctly" do
      post "/ratings/rating-type.json", params: create_params
      expect(response.status).to eq(200)
      expect(DiscourseRatings::RatingType.all.map { |t| t.type }).to include(
        create_params[:type]
      )
    end
  end

  describe "#update" do
    it "updates the rating type correctly" do
      DiscourseRatings::RatingType.create(
        create_params[:type],
        create_params[:name]
      )
      put "/ratings/rating-type/" + update_params[:type] + ".json",
          params: update_params
      expect(response.status).to eq(200)
      expect(DiscourseRatings::RatingType.get_name(create_params[:type])).to eq(
        update_params[:name]
      )
    end
  end

  describe "#destroy" do
    it "destroys the rating type" do
      DiscourseRatings::RatingType.create(
        create_params[:type],
        create_params[:name]
      )
      delete "/ratings/rating-type/" + create_params[:type] + ".json",
             params: delete_params
      expect(response.status).to eq(200)
      expect(response.parsed_body["success"]).to eq("OK")
      expect(Jobs::DestroyRatingType.jobs.size).to eq(1)
      job_data = Jobs::DestroyRatingType.jobs.first["args"].first
      expect(job_data["type"]).to eq("comfort")
      expect(job_data["current_site_id"]).to eq("default")
    end
    # it "gives 400 error for invalid data" do
    #   delete "/ratings/rating-type/" + create_params[:type] + ".json",
    #          params: delete_params
    #   expect(response.status).to eq(400)
    #   expect(response.parsed_body["error_type"]).to eq("invalid_parameters")
    #   expect(Jobs::DestroyRatingType.jobs.size).to eq(0)
    # end
  end
end

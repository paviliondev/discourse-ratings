# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::RatingController do
  it "is a subclass of AdminController" do
    expect(DiscourseRatings::RatingController < ::Admin::AdminController)
  end

  let!(:rating_type_params) { { type: "discipline", name: "Discipline" } }
  let!(:category) { Fabricate(:category) }
  let!(:migrate_params) do
    { category_id: category.id, type: "discipline", new_type: "none" }
  end
  let!(:migrate_params_non_existent) do
    { category_id: category.id, type: "none", new_type: "discipline" }
  end
  let(:none_rating_hash) do
    JSON.parse('[{"type":"none","value":"4", "pavilion": "yes"}]')
  end
  let!(:destroy_params) { { category_id: category.id } }

  context "not logged in" do
    describe "#destroy" do
      it "blocks non-admin" do
        DiscourseRatings::RatingType.create(
          rating_type_params[:type],
          rating_type_params[:name]
        )

        delete "/ratings/rating/#{rating_type_params[:type]}.json",
               params: destroy_params
        expect(response.status).to eq(404)
        expect(response.parsed_body["error_type"]).to eq("not_found")
      end
    end
  end

  context "authenticated" do
    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }
    describe "#migrate" do
      it "migrates the rating to other category" do
        DiscourseRatings::RatingType.create(
          rating_type_params[:type],
          rating_type_params[:name]
        )

        post "/ratings/rating/migrate.json", params: migrate_params
        #testing the job if is working or not is not neccesary
        expect(response.status).to eq(200)
        expect(response.parsed_body["success"]).to eq("OK")

        expect(Jobs::MigrateRatings.jobs.size).to eq(1)

        job_data = Jobs::MigrateRatings.jobs.first["args"].first
        expect(job_data["category_id"].to_i).to eq(category.id)
        expect(job_data["type"]).to eq("discipline")
        expect(job_data["new_type"]).to eq("none")
      end

      it "errors when second parameter is invalid" do
        post "/ratings/rating/migrate.json", params: migrate_params_non_existent
        #testing the job if is working or not is not neccesary
        expect(response.status).to eq(400)
        expect(response.parsed_body["error_type"]).to eq("invalid_parameters")

        expect(Jobs::MigrateRatings.jobs.size).to eq(0)
      end

      it "errors when first parameters is invalid" do
        post "/ratings/rating/migrate.json", params: migrate_params
        expect(response.status).to eq(400)
        expect(response.parsed_body["error_type"]).to eq("invalid_parameters")
      end
    end

    describe "#destroy" do
      it "destroys the rating type" do
        DiscourseRatings::RatingType.create(
          rating_type_params[:type],
          rating_type_params[:name]
        )

        delete "/ratings/rating/#{rating_type_params[:type]}.json",
               params: destroy_params
        expect(response.status).to eq(200)
        expect(response.parsed_body["success"]).to eq("OK")
      end
    end
  end
end

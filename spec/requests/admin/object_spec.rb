# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::ObjectController do
  let!(:rating_type) { "none" }
  let!(:other_rating_type) { "discipline" }
  let!(:other_rating_name) { "Discipline" }
  let!(:rating_category) { Fabricate(:category) }
  let!(:create_rating_type) do
    { type: "category", name: rating_category.rating_key, types: [rating_type] }
  end
  let!(:update_rating_type) do
    {
      type: "category",
      name: rating_category.rating_key,
      types: [rating_type, other_rating_type],
    }
  end
  let!(:delete_rating_type) do
    { type: "category", name: rating_category.rating_key }
  end
  let!(:create_rating_type_error) do
    {
      type: "cate",
      name: rating_category.rating_key,
      types: [other_rating_type],
    }
  end
  let!(:rating_tag) { Fabricate(:tag) }
  # it "is a subclass of AdminController" do
  #   expect(DiscourseRatings::ObjectController < ::Admin::AdminController)
  # end
  context "authenticated" do
    let(:admin) { Fabricate(:admin) }

    before { sign_in(admin) }
    describe "#create" do
      it "errors when type is incorrect" do
        post "/ratings/object.json", params: create_rating_type_error
        expect(response.status).to eq(400)
        expect(response.parsed_body["error_type"]).to eq("invalid_parameters")
        expect(rating_category.rating_types).not_to include(other_rating_type)
      end
      it "errors when category already exists" do
        DiscourseRatings::Object.create(
          "category",
          rating_category.rating_key,
          [rating_type]
        )
        post "/ratings/object.json", params: create_rating_type
        expect(response.status).to eq(400)
        expect(response.parsed_body["error_type"]).to eq("invalid_parameters")
      end
      it "creates a new category rating" do
        post "/ratings/object.json", params: create_rating_type
        expect(response.status).to eq(200)
        expect(response.parsed_body["success"]).to eq("OK")
        expect(
          DiscourseRatings::Object.exists?(
            "category",
            rating_category.rating_key
          )
        ).to eq(true)
        expect(rating_category.rating_types).to include(rating_type)
      end
    end

    describe "#show" do
      it "displays a category rating" do
        DiscourseRatings::Object.create(
          "category",
          rating_category.rating_key,
          [rating_type]
        )
        get "/ratings/object/category.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body.first["name"]).to eq(
          rating_category.rating_key
        )
        expect(response.parsed_body.first["types"]).to eq([rating_type])
      end
    end

    describe "#update" do
      it "updates existing category rating" do
        DiscourseRatings::Object.create(
          "category",
          rating_category.rating_key,
          [rating_type]
        )
        DiscourseRatings::RatingType.create(
          other_rating_type,
          other_rating_name
        )
        put "/ratings/object/category.json", params: update_rating_type
        expect(response.status).to eq(200)
        expect(rating_category.rating_types).to include(rating_type)
        expect(rating_category.rating_types).to include(other_rating_type)
      end
    end

    describe "#destroy" do
      it "destroys a category rating" do
        DiscourseRatings::Object.create(
          "category",
          rating_category.rating_key,
          [rating_type]
        )
        delete "/ratings/object/category.json", params: delete_rating_type
        expect(response.status).to eq(200)
        expect(
          DiscourseRatings::Object.exists?(
            "category",
            rating_category.rating_key
          )
        ).to eq(false)
      end
    end
  end
end

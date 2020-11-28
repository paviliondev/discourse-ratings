# frozen_string_literal: true
describe DiscourseRatings::RatingTypeController do
  let!(:create_params) do
    { type: 'comfort', name: 'Comfort' }
  end
    let!(:update_params) do
      { type: 'comfort', name: 'Comfort Zone' }
    end
    fab!(:admin) { sign_in(Fabricate(:admin)) }

    describe "#create" do
      it "creates the rating type correctly" do
        post "/ratings/rating-type", params: create_params
          expect(response.status).to eq(200)
      end
    end

    describe "#update" do
      it "updates the rating type correctly" do
        DiscourseRatings::RatingType.create(create_params[:type], create_params[:name])
          put "/ratings/rating-type/" + update_params[:type], params: update_params
          expect(response.status).to eq(200)
      end
    end
end

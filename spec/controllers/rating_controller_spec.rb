require 'rails_helper'

describe ::DiscourseRatings::RatingController do
  routes { ::DiscourseRatings::Engine.routes }

  let(:category) { Fabricate(:category, custom_fields: { rating_enabled: true }) }
  let(:topic) { Fabricate(:topic, category_id: category.id) }
  let!(:post_1) { Fabricate(:post, topic_id: topic.id) }

  describe "rate" do

    it 'works' do
      xhr :post, :rate, post_id: post_1.id, rating: 3
      expect(response).to be_success

      expect(post_1.custom_fields['rating']).to eq('3')
      expect(post_1.custom_fields['rating_weight']).to eq('1')
      expect(topic.custom_fields['average_rating']).to eq('3.0')
    end

    describe 'with 2 ratings' do
      let!(:post_2) { Fabricate(:post, topic_id: topic.id) }

      it "updates the topic average correctly" do
        xhr :post, :rate, post_id: post_1.id, rating: 3
        expect(response).to be_success

        xhr :post, :rate, post_id: post_2.id, rating: 1
        expect(response).to be_success

        expect(post_2.custom_fields['rating']).to eq('1')
        expect(post_2.custom_fields['rating_weight']).to eq('1')
        expect(topic.custom_fields['average_rating']).to eq('2.0')
      end
    end
  end
end

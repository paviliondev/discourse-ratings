require 'rails_helper'

describe PostsController do
  let!(:user) { log_in }

  let(:category) { Fabricate(:category, custom_fields: { rating_enabled: true }) }
  let(:topic) { Fabricate(:topic, category_id: category.id) }

  describe 'post rating' do
    it 'works' do
      params = { topic_id: topic.id, title: 'Testing Ratings Plugin', raw: 'New rating', rating: 3 }
      post :create, params: params, format: :json
      expect(response).to be_success
      json = ::JSON.parse(response.body)
      expect(PostCustomField.find_by(
        post_id: json['id'],
        name: 'rating'
      ).value).to eq('3')
      expect(PostCustomField.find_by(
        post_id: json['id'],
        name: 'rating_weight'
      ).value).to eq('1')
      expect(TopicCustomField.find_by(
        topic_id: json['topic_id'],
        name: 'average_rating'
      ).value).to eq('3.0')
    end
  end
end

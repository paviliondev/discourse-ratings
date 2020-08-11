require 'rails_helper'

describe PostSerializer do
  fab!(:rating_type_name) { 'spec' }
  fab!(:rating_type_id) { DiscourseRatings::RatingType.create(rating_type_name, 'Spec'); PluginStoreRow.find_by(plugin_name: ::DiscourseRatings::PLUGIN_NAME, key: "type_#{rating_type_name}").id }
  let(:rating_hash) { { type: rating_type_name, value: 3, weight: 1} }
  fab!(:rating_category) { Fabricate(:category) }
  fab!(:enable_on_cat) { ::DiscourseRatings::Object.create('category', rating_category.rating_key, [rating_type_name]) }
  
  fab!(:user1) { Fabricate(:user) }
  fab!(:rating_topic) {Fabricate(:topic, user: user1, category: rating_category)}
  fab!(:post) { Fabricate(:post, user: user1, topic: rating_topic) }
  fab!(:user2) { Fabricate(:user) }
  fab!(:admin) { Fabricate(:admin) }

  describe '#ratings' do
    before do
      DiscourseRatings::Rating.build_and_set(post, rating_hash)
      post.save_custom_fields(true)

      SiteSetting.rating_hide_except_own_entry = true
    end
    
    it 'serializes ratings if the rating is by the author himself' do
      serializer = PostSerializer.new(post, scope: Guardian.new(user1), root: false)
      rating_data = serializer.as_json[:ratings].as_json
      expect(rating_data).not_to eq([])
      expect(rating_data[0][:type]).to eq('spec')
      expect(rating_data[0][:value]).to eq(3)
    end

    it 'doesn\'t serialize ratings if the rating is by the another user' do
      serializer = PostSerializer.new(post, scope: Guardian.new(user2), root: false)
      expect(serializer.as_json[:ratings]).to eq(nil)
    end

    it 'bypasses the restrictions for staff/admin' do
      serializer = PostSerializer.new(post, scope: Guardian.new(admin), root: false)
      rating_data = serializer.as_json[:ratings].as_json
      expect(rating_data).not_to eq([])
      expect(rating_data[0][:type]).to eq('spec')
      expect(rating_data[0][:value]).to eq(3)
    end
  end
end
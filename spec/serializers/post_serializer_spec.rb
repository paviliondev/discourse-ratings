# frozen_string_literal: true

require_relative "../plugin_helper.rb"

describe PostSerializer do
  let!(:post_rating) { { type: "spec", value: 3, weight: 1 } }
  let!(:user1) { Fabricate(:user) }
  let!(:rating_post) { Fabricate(:post, user: user1) }
  let!(:user2) { Fabricate(:user) }
  let!(:admin) { Fabricate(:admin) }

  describe "#ratings" do
    before do
      rating_post.stubs(:ratings).returns(DiscourseRatings::Rating.build_list([post_rating]))
      SiteSetting.rating_hide_except_own_entry = true
    end

    it "serializes ratings if the rating is by the author himself" do
      serializer = PostSerializer.new(rating_post, scope: Guardian.new(user1), root: false)
      rating_data = serializer.as_json[:ratings].as_json
      expect(rating_data).not_to eq([])
      expect(rating_data[0][:type]).to eq("spec")
      expect(rating_data[0][:value]).to eq(3)
    end

    it "respects plugin enabled setting" do
      SiteSetting.rating_enabled = false
      serializer = PostSerializer.new(rating_post, scope: Guardian.new(user1), root: false)
      rating_data = serializer.as_json[:ratings].as_json
      expect(rating_data).to eq(nil)
    end

    it 'doesn\'t serialize ratings if the rating is by the another user' do
      serializer = PostSerializer.new(rating_post, scope: Guardian.new(user2), root: false)
      expect(serializer.as_json[:ratings]).to eq(nil)
    end

    it "bypasses the restrictions for staff/admin" do
      serializer = PostSerializer.new(rating_post, scope: Guardian.new(admin), root: false)
      rating_data = serializer.as_json[:ratings].as_json
      expect(rating_data).not_to eq([])
      expect(rating_data[0][:type]).to eq("spec")
      expect(rating_data[0][:value]).to eq(3)
    end
  end
end

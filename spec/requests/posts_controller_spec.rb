# frozen_string_literal: true
require "rails_helper"

describe PostsController do
  let(:rating_hash) { JSON.parse('[{"type":"pointers","value":"4", "pavilion": "yes"}]') }
  let(:rating_none_type) { 'none' }
  let(:rating_none_name) { 'None' }
  fab!(:rating_category) { Fabricate(:category) }
  fab!(:user) { sign_in(Fabricate(:user)) }
  fab!(:rating_topic) { Fabricate(:topic, category: rating_category) }
  fab!(:rating_post) { Fabricate(:post, topic: rating_topic, user: user) }
  let(:none_rating_json) { '[{"type":"none","value":"4", "pavilion": "yes"}]' }
  let(:multiple_rating_hash) { JSON.parse('[{"type":"pointers","value":"4", "pavilion": "yes"}, {"type":"handwriting","value":"3"}]') }
  let(:update_params) do
    {
        post: {
          raw: 'edited body',
          ratings: none_rating_json,
        }
    }
  end

  it "updates the rating correctly" do
    SiteSetting.rating_enabled = true

    post = Fabricate(:post, user: user)
    DiscourseRatings::Rating.build_and_set(post, rating_hash)
    post.save_custom_fields(true)
    Category.any_instance.stubs(:rating_types).returns([rating_none_type])
    put "/posts/#{post.id}.json", params: update_params
    expect(response.status).to eq(200)
    # rating isn't being updated coz rating type settings are not in place
    post.reload
    expect(post.custom_fields['rating_none']).to be_present
  end
end

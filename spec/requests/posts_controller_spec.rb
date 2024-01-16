# frozen_string_literal: true

require_relative "../plugin_helper.rb"

describe PostsController do
  let(:rating_hash) { JSON.parse('[{"type":"pointers","value":"4", "pavilion": "yes"}]') }
  let(:rating_none_type) { "none" }
  let(:rating_none_name) { "None" }
  fab!(:rating_category) { Fabricate(:category) }
  fab!(:user) { sign_in(Fabricate(:user, refresh_auto_groups: true)) }
  fab!(:rating_topic) { Fabricate(:topic, category: rating_category) }
  fab!(:rating_post) { Fabricate(:post, topic: rating_topic, user: user) }
  let(:none_rating_json) { '[{"type":"none","value":"4", "pavilion": "yes"}]' }
  let(:multiple_rating_hash) do
    JSON.parse(
      '[{"type":"pointers","value":"4", "pavilion": "yes"}, {"type":"handwriting","value":"3"}]',
    )
  end
  let(:create_params) do
    { raw: "new body", ratings: none_rating_json, topic_id: rating_topic.id, user_id: user.id }
  end
  let(:update_params) { { post: { raw: "edited body", ratings: none_rating_json } } }
  it "adds the the rating correctly" do
    SiteSetting.rating_enabled = true

    Category.any_instance.stubs(:rating_types).returns([rating_none_type])
    post "/posts.json", params: create_params
    expect(response.status).to eq(200)

    post_id = JSON.parse(response.body)["id"]
    post = Post.find(post_id)
    expect(post.custom_fields["rating_none"]).to be_present
  end

  it "updates the rating correctly" do
    SiteSetting.rating_enabled = true

    post = Fabricate(:post, user: user)
    DiscourseRatings::Rating.build_and_set(post, rating_hash)
    post.save_custom_fields(true)
    Category.any_instance.stubs(:rating_types).returns([rating_none_type])
    put "/posts/#{post.id}.json", params: update_params
    expect(response.status).to eq(200)
    post.reload
    expect(post.custom_fields["rating_none"]).to be_present
  end
end

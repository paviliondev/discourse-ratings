# frozen_string_literal: true

require_relative "../plugin_helper.rb"
require "post_revisor"

describe PostRevisor do
  let!(:post_rating_param) { { type: "awesomeness", value: 4, weight: 1 } }
  let!(:post_rating_update_param) { { type: "awesomeness", value: 3, weight: 1 } }
  let!(:rating_category) { Fabricate(:category) }
  let!(:rating_topic) { Fabricate(:topic, category: rating_category) }
  let!(:rating_post) { Fabricate(:post, topic: rating_topic) }
  before do
    Category.any_instance.stubs(:rating_types).returns(["awesomeness"])
    DiscourseRatings::Rating.build_and_set(rating_post, post_rating_param)
    rating_post.save_custom_fields(true)
  end

  it "detects change in rating" do
    pr = PostRevisor.new(rating_post)
    ## write rating to cache to simulate what posts_controller patch does
    new_ratings = DiscourseRatings::Rating.build_list([post_rating_update_param])
    DiscourseRatings::Cache.new("update_#{rating_post.id}").write(new_ratings)
    pr.revise!(rating_post.user, ratings: new_ratings)
    rating_post.reload

    expect(rating_post.ratings[0].value).to eq(3.0)
  end

  it "does not error out if post's topic has been deleted first" do
    rating_post.topic.destroy
    rating_post.reload

    expect { rating_post.ratings }.not_to raise_error
  end
end

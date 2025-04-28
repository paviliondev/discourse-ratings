# frozen_string_literal: true

require_relative "../plugin_helper.rb"

describe Jobs::DestroyRatingType do
  let!(:rating_category) { Fabricate(:category) }
  let!(:rating_topic) { Fabricate(:topic, category: rating_category) }
  let!(:rating_post) { Fabricate(:post, topic: rating_topic) }
  let!(:rating_type) { "interest" }
  let!(:rating_type_name) { "Interest" }
  let(:rating_hash) { JSON.parse('[{"type":"interest","value":"4", "weight":1}]') }

  def data_exists_after_creation?
    expect(rating_category.reload.rating_types).to eq([rating_type])
    expect(rating_topic.reload.ratings).to be_present
    expect(rating_post.reload.ratings).to be_present

    job = described_class.new
    job.execute(type: rating_type)
  end

  before do
    DiscourseRatings::RatingType.create(rating_type, rating_type_name)
    DiscourseRatings::Object.create("category", rating_category.rating_key, [rating_type])
    DiscourseRatings::Rating.build_and_set(rating_post, rating_hash)
    rating_post.save_custom_fields(true)
    rating_post.update_topic_ratings
    data_exists_after_creation?
  end

  it "clears the post custom fields " do
    expect(rating_post.reload.ratings).not_to be_present
  end

  it "clears the topic custom fields " do
    expect(rating_topic.reload.ratings).not_to be_present
  end

  it "clears the category association" do
    expect(rating_category.rating_types).to eq([])
  end

  it "deletes the rating type itself" do
    expect(DiscourseRatings::RatingType.all).not_to include(rating_type)
  end
end

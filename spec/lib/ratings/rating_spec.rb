# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::Rating do
  let(:rating_hash) { JSON.parse('[{"type":"pointers","value":"4", "pavilion": "yes"}]') }
  let(:none_rating_hash) { JSON.parse('[{"type":"none","value":"4", "pavilion": "yes"}]') }
  let(:multiple_rating_hash) do
    JSON.parse(
      '[{"type":"pointers","value":"4", "pavilion": "yes"}, {"type":"handwriting","value":"3"}]',
    )
  end

  describe "#build_list" do
    let(:rating) { DiscourseRatings::Rating.build_list(rating_hash) }

    it "builds the model list correctly" do
      expect(rating).to be_present
      expect(rating.class).to eq(Array)
    end
  end

  describe "#build_and_set" do
    let(:rating_topic) { Fabricate(:topic) }

    before { DiscourseRatings::Rating.build_and_set(rating_topic, rating_hash) }

    let(:parsed_object) { JSON.parse(rating_topic.custom_fields["rating_pointers"]) }

    it "sets the custom fields correctly on the model" do
      expect(rating_topic.custom_fields["rating_pointers"]).to be_present
      expect(parsed_object["value"]).to eq(4.0)
    end

    it "ignores extra fields if any" do
      expect(parsed_object["pavilion"]).not_to be_present
    end
  end

  describe "#build_model_list" do
    let(:rating_topic_1) { Fabricate(:topic) }
    let(:rating_post) { Fabricate(:post, topic: rating_topic_1) }

    before { DiscourseRatings::Rating.build_and_set(rating_post, multiple_rating_hash) }

    it "builds the correct list based on types passed" do
      rating_list =
        DiscourseRatings::Rating.build_model_list(rating_post.custom_fields, ["handwriting"])
      expect(rating_list.length).to eq(1)
      expect(rating_list[0].class).to eq(DiscourseRatings::Rating)
      expect(rating_list[0].type).to eq("handwriting")
    end
  end

  describe "#destroy" do
    it "destroys the ratings from topics and posts" do
      #set rating on a few topics and post and destroy should remove all the related custom fields

      topic_1 = Fabricate(:topic)
      topic_2 = Fabricate(:topic)

      post_1 = Fabricate(:post)
      post_2 = Fabricate(:post)

      [topic_1, topic_2, post_1, post_2].each do |item|
        DiscourseRatings::Rating.build_and_set(item, multiple_rating_hash)
      end

      [topic_1, topic_2, post_1, post_2].each do |item|
        expect(item.custom_fields["rating_pointers"]).to be_present
      end

      DiscourseRatings::Rating.destroy(type: "pointers")

      [topic_1, topic_2, post_1, post_2].each { |item| item.reload }

      [topic_1, topic_2, post_1, post_2].each do |item|
        expect(item.custom_fields["rating_pointers"]).to eq(nil)
      end
    end
  end

  describe "#migrate" do
    it "migrates the ratings to a new type" do
      #set rating on a few topics and post and destroy should remove all the related custom fields

      topic_1 = Fabricate(:topic)
      topic_2 = Fabricate(:topic)

      post_1 = Fabricate(:post, topic: topic_1)
      post_2 = Fabricate(:post, topic: topic_2)

      [topic_1, topic_2, post_1, post_2].each do |item|
        DiscourseRatings::Rating.build_and_set(item, none_rating_hash)
        item.save_custom_fields(true)
        expect(item.custom_fields["rating_none"]).to be_present
      end

      DiscourseRatings::Rating.migrate(type: "none", new_type: "discipline")

      [topic_1, topic_2, post_1, post_2].each do |item|
        item.reload
        expect(item.custom_fields["rating_none"]).to eq(nil)
        expect(item.custom_fields["rating_discipline"]).to be_present
      end
    end
  end
end

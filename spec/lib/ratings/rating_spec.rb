# frozen_string_literal: true
require "rails_helper"

describe DiscourseRatings::Rating do
  let(:rating_hash) { JSON.parse('[{"type":"pointers","value":"4", "pavilion": "yes"}]')}
  let(:multiple_rating_hash) { JSON.parse('[{"type":"pointers","value":"4", "pavilion": "yes"}, {"type":"handwriting","value":"3"}]')}

  describe "#build_list" do
    let(:rating) { DiscourseRatings::Rating.build_list(rating_hash)}

    it "builds the model list correctly" do
      expect(rating).to be_present
      expect(rating.class).to eq(Array)
    end

  end

  describe "#build_and_set" do
    let(:rating_topic) { Fabricate(:topic) }

    before do
      DiscourseRatings::Rating.build_and_set(rating_topic, rating_hash)
    end

    let(:parsed_object) { JSON.parse(rating_topic.custom_fields['rating_pointers']) }

    it "sets the custom fields correctly on the model" do
      expect(rating_topic.custom_fields['rating_pointers']).to be_present
      expect(parsed_object['value']).to eq(4.0)
    end

    it "ignores extra fields if any" do
      expect(parsed_object['pavilion']).not_to be_present
    end
  end

  describe "#build_model_list" do
    let(:rating_topic_1) { Fabricate(:topic) }
    let(:rating_post) { Fabricate(:post, topic: rating_topic_1) }

    before do
      DiscourseRatings::Rating.build_and_set(rating_post, multiple_rating_hash)
    end

    it "builds the correct list based on types passed" do
      rating_list = DiscourseRatings::Rating.build_model_list(rating_post.custom_fields, ["handwriting"])
      expect(rating_list.length).to eq(1)
      expect(rating_list[0].class).to eq(DiscourseRatings::Rating)
      expect(rating_list[0].type).to eq("handwriting")
    end
  end
end

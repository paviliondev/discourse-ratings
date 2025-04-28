# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::RatingType do
  let!(:type_param) { "coolness" }
  let!(:name_param) { "Coolness" }
  before { DiscourseRatings::RatingType.create(type_param, name_param) }

  it "saves the type" do
    type_exists = DiscourseRatings::RatingType.exists?(type_param)
    expect(type_exists).to eq(true)
  end

  it "includes the created type in the list" do
    all_types = DiscourseRatings::RatingType.all
    expect(all_types.map { |rating_type| rating_type.type }).to include(type_param)
  end

  it "modifies the type name correctly" do
    DiscourseRatings::RatingType.set(type_param, "Intelligence")
    expect(DiscourseRatings::RatingType.get(type_param)).to eq("Intelligence")
  end

  it "correctly updates the cache" do
    DiscourseRatings::RatingType.create("professionalism", "Professionalism")
    cached_list = DiscourseRatings::RatingType.cached_list.map { |rating_type| rating_type.type }
    list = DiscourseRatings::RatingType.all.map { |rating_type| rating_type.type }
    expect(list).to eq(cached_list)
  end

  it "destroys the type correctly" do
    DiscourseRatings::RatingType.destroy("coolness")
    all_types = DiscourseRatings::RatingType.all
    expect(all_types.map { |rating_type| rating_type.type }).not_to include(type_param)
  end
end

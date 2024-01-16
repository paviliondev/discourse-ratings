# frozen_string_literal: true

require_relative "../../plugin_helper.rb"

describe DiscourseRatings::Cache do
  it "writes and reads values to the cache" do
    DiscourseRatings::Cache.new("list").write([1, 2, 3])
    expect(DiscourseRatings::Cache.new("list").read).to eq([1, 2, 3])
  end

  it "deletes values from the cache" do
    DiscourseRatings::Cache.new("list").delete
    expect(DiscourseRatings::Cache.new("list").read).to eq(nil)
  end

  describe "#wrap" do
    before { Discourse.cache.clear }

    it "caches the value if non existant" do
      wrapped = DiscourseRatings::Cache.wrap("sample") { [1, 2, 3] }
      cached = DiscourseRatings::Cache.new("sample")
      expect(cached.read).to eq([1, 2, 3])
    end

    it "evaluates the block only if cache is empty" do
      value = [1, 2, 3]
      cache = DiscourseRatings::Cache.new("testkey")
      wrapped = DiscourseRatings::Cache.wrap("testkey") { value }
      expect(wrapped).to eq(value)

      new_value = [3, 2, 1]
      wrapped_new = DiscourseRatings::Cache.wrap("testkey") { new_value }
      expect(cache.read).to eq(value)

      cache.delete
      wrapped_new = DiscourseRatings::Cache.wrap("testkey") { new_value }
      expect(wrapped_new).to eq(new_value)
    end
  end
end

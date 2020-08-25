# frozen_string_literal: true
require "rails_helper"

describe DiscourseRatings::Cache do

  describe "#wrap" do 
    it "caches the value if non existant" do 
      wrapped = DiscourseRatings::Cache.wrap('sample') { [1,2,3] }
      cached = DiscourseRatings::Cache.new('sample')
      expect(cached.read).to eq([1,2,3])
    end
  end
end
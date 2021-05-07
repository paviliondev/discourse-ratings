# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  root "plugins/discourse-ratings"
  track_files "plugins/discourse-ratings/**/*.rb"
  add_filter { |src| src.filename =~ /(\/spec\/|\/db\/|plugin\.rb)/ }
  SimpleCov.minimum_coverage 80
end

require 'rails_helper'

RSpec.configure do |config|
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

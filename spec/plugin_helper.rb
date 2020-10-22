# frozen_string_literal: true
require 'simplecov'

SimpleCov.configure do
  add_filter do |src|
    src.filename !~ /discourse-ratings/ ||
    src.filename =~ /spec/
  end
end

RSpec.configure do |config|
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

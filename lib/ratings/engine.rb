# frozen_string_literal: true
module ::DiscourseRatings
  class Engine < ::Rails::Engine
    engine_name "discourse_ratings"
    isolate_namespace DiscourseRatings
  end
  PLUGIN_NAME ||= "discourse_ratings"
end

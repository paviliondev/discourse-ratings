# frozen_string_literal: true
module TopicRatingsExtension
  def preload_custom_fields(objects, fields)
    ## Remove all rating types
    fields = fields.select { |f| !f.starts_with?("#{DiscourseRatings::Rating::KEY}_") }

    ## Build list of current types (type list is cached)
    type_list =
      DiscourseRatings::RatingType.cached_list.map(&:type) + [DiscourseRatings::RatingType::NONE]
    rating_types = type_list.map { |t| DiscourseRatings::Rating.field_name(t) }

    ## Add types to preloaded fields
    fields.push(*rating_types)
    super
  end
end

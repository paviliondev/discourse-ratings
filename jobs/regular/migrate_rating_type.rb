# frozen_string_literal: true

module Jobs
  class MigrateRatingType < ::Jobs::Base
    def execute(args)
      %i{
        category_id
        current_type
        new_type
      }.each do |key|
        raise Discourse::InvalidParameters.new(key) if args[key].blank?
      end
      
      ### currently you can only migrate to and from none
      if [args[:current_type], args[:new_type]].exclude?(DiscourseRatings::RatingType::NONE)
        raise Discourse::InvalidParameters.new
      end
      
      current_name = "#{DiscourseRatings::Rating::KEY}_#{args[:current_type]}"
      new_name = "#{DiscourseRatings::Rating::KEY}_#{args[:new_type]}"
      
      topic_ids = Topic.where("
        category_id = #{args[:category_id]} AND id in (
          SELECT topic_id FROM topic_custom_fields
          WHERE name = '#{current_name}'
        )
      ").pluck(:id)
      post_ids = Post.where(topic_id: topic_ids).pluck(:id)
      
      TopicCustomField.where(topic_id: topic_ids, name: current_name).update_all(name: new_name)
      PostCustomField.where(post_id: post_ids, name: current_name).update_all(name: new_name)
    end
  end
end

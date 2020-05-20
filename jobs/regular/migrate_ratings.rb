# frozen_string_literal: true

module Jobs
  class MigrateRatings < ::Jobs::Base
    def execute(args)
      %i{
        category_id
        type
      }.each do |key|
        raise Discourse::InvalidParameters.new(key) if args[key].blank?
      end
      
      update_sql = "value = jsonb_set(value, '{type}', to_json(#{type})::jsonb)"
      
      topic_ids = Topic.where(category_id: category_id)
        .includes(:topic_custom_fields)
        .where("topic_custom_fields.ratings IS NOT NULL")
        .where("topic_custom_fields.ratings->>'type' = ?", type)
        .pluck(:id)
      TopicCustomField.where(topic_id: topic_ids).update_all(update_sql)
      
      post_ids = Post.where(topic_id: topic_ids).pluck(:id)
      PostCustomField.where(post_id: post_ids).update_all(update_sql)
    end
  end
end

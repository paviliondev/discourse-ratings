# frozen_string_literal: true
module PostRevisorRatingsExtension
  def ratings_cache
    DiscourseRatings::Cache.new("update_#{@post.id}")
  end

  def ratings
    @ratings ||= ratings_cache.read
  end

  def clear_ratings_cache!
    ratings_cache.delete
    @ratings = nil
  end

  def should_revise?
    super || ratings_changed?
  end

  def ratings_changed?
    return false unless ratings.present?
    return true unless @post.ratings.present?
    return true if @post.ratings.length != ratings.length

    ratings.any? do |r|
      @post.ratings.any? do |pr|
        pr.type === r.type && (pr.value != r.value || pr.weight != r.weight)
      end
    end
  end
end

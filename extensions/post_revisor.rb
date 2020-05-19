module PostRevisorRatingsExtension
  def should_revise?
    super || ratings_changed?
  end
  
  def ratings_changed?
    return false unless ratings.present?
    return true unless @post.ratings.present?
    return true if @post.ratings.length != ratings.length
    
    ratings.any? do |r|
      @post.ratings.any? do |pr|
        pr.type === r['type'] && pr.value != r['value']
      end
    end
  end
end
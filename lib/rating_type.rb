class DiscourseRatings::RatingType
  KEY_PREFIX ||= "type_"
  NONE ||= "none"
  
  def self.all
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{KEY_PREFIX}%'
    ")
  end

  def self.exists?(slug)
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key = ?
    ", slug).exists?
  end
  
  def self.create(slug, name)
    return false if slug.dasherize == NONE
    self.set(KEY_PREFIX + slug.dasherize, name)
  end
  
  def self.get(slug)
    PluginStore.get(DiscourseRatings::PLUGIN_NAME, slug)
  end
  
  def self.set(slug, name)
    PluginStore.set(DiscourseRatings::PLUGIN_NAME, slug, name)
  end
  
  def self.destroy(slug)
    PluginStore.remove(DiscourseRatings::PLUGIN_NAME, slug)
  end
end
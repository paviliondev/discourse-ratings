class DiscourseRatings::RatingType
  KEY_PREFIX ||= "type_"
  NONE ||= "none"
  
  def self.all
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{KEY_PREFIX}%'
    ")
  end

  def self.exists?(type)
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key = ?
    ", build_key(type)).exists?
  end
  
  def self.create(type, name)
    type = type.underscore
    return false if type == NONE ## none type can only be set via bulk operation
    self.set(build_key(type), name)
  end
  
  def self.get(type)
    PluginStore.get(DiscourseRatings::PLUGIN_NAME, build_key(type))
  end
  
  def self.set(type, name)
    PluginStore.set(DiscourseRatings::PLUGIN_NAME, build_key(type), name)
  end
  
  def self.destroy(type)
    PluginStore.remove(DiscourseRatings::PLUGIN_NAME, build_key(type))
  end
  
  private
  
  def self.build_key(type)
    KEY_PREFIX + type.underscore
  end
end
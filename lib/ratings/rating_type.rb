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
    preload_custom_fields
  end
  
  def self.destroy(type)
    PluginStore.remove(DiscourseRatings::PLUGIN_NAME, build_key(type))
  end
  
  def self.preload_custom_fields
    all.each do |row|
      type = row.key.split(DiscourseRatings::RatingType::KEY_PREFIX).last
      TopicList.preloaded_custom_fields << "#{DiscourseRatings::Rating::KEY}_#{type}"
    end 
  end
  
  def self.migrate(data)
    Jobs.enqueue(:migrate_rating_type, data)
  end
  
  private
  
  def self.build_key(type)
    KEY_PREFIX + type.underscore
  end
end
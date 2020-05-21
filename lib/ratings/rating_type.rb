class DiscourseRatings::RatingType
  KEY ||= "type"
  NONE ||= "none"
  
  def self.all
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{KEY}_%'
    ")
  end
  
  def self.list
    DiscourseRatings::Cache.wrap("#{KEY}_list") do
      all.map { |row| type_from_key(row.key) }
    end
  end
  
  def self.clear_cached_list
    DiscourseRatings::Cache.new("#{KEY}_list").delete
  end

  def self.exists?(type)
    return true if type == NONE
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key = ?
    ", build_key(type)).exists?
  end
  
  def self.create(type, name)
    return false if type == NONE ## none type can only be set via bulk operation
    self.set(type, name)
  end
  
  def self.get(type)
    PluginStore.get(DiscourseRatings::PLUGIN_NAME, build_key(type))
  end
  
  def self.set(type, name)
    PluginStore.set(DiscourseRatings::PLUGIN_NAME, build_key(type), name)
    clear_cached_list
  end
  
  def self.destroy(type)
    PluginStore.remove(DiscourseRatings::PLUGIN_NAME, build_key(type))
    clear_cached_list
  end
    
  def self.build_key(type)
    "#{KEY}_#{type.parameterize.underscore}"
  end
  
  def self.type_from_key(key)
    key.split('_', 2).last
  end
end
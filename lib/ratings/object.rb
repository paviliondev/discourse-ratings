class DiscourseRatings::Object
  include ActiveModel::SerializerSupport
  
  TYPES ||= %w[category tag]
  
  attr_accessor :name, :types
  
  def initialize(name, types)
    @name = name
    @types = types
  end
  
  def self.list(object_type)
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{object_type}_%'
    ").map do |record|
      new(record.key.split('_').last, record.value.split("|"))
    end
  end
  
  def self.exists?(object_type, name)
    PluginStoreRow.where("
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key = ?
    ", build_key(object_type, name)).exists?
  end
  
  def self.create(object_type, name, types)
    if exists?(object_type, name) ||
       object_type.blank? ||
       name.blank? ||
       types.blank?
       
      false
    else
      set(object_type, name, types)
    end
  end
  
  def self.get(object_type, name)
    if (types = PluginStore.get(DiscourseRatings::PLUGIN_NAME, build_key(object_type, name))).present?
      types.split('|')
    else
      []
    end
  end
  
  def self.set(object_type, name, types)
    if TYPES.include?(object_type)
      PluginStore.set(DiscourseRatings::PLUGIN_NAME, build_key(object_type, name), types.join('|'))
    end
  end
  
  def self.destroy(object_type, name)
    PluginStore.remove(DiscourseRatings::PLUGIN_NAME, build_key(object_type, name))
  end
  
  private
  
  def self.build_key(object_type, name)
    "#{object_type}_#{name}"
  end
end
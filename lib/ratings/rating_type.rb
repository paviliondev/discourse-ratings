# frozen_string_literal: true
class DiscourseRatings::RatingType
  include ActiveModel::SerializerSupport

  KEY ||= "type"
  NONE ||= "none"

  attr_accessor :type, :name

  def initialize(attrs)
    @type = attrs[:type]
    @name = attrs[:name]
  end

  def self.all
    PluginStoreRow
      .where(
        "
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{KEY}_%'
    ",
      )
      .map { |row| new(type: type_from_key(row.key), name: row.value) }
  end

  def self.cached_list
    DiscourseRatings::Cache.wrap("#{KEY}_list") { all }
  end

  def self.clear_cached_list
    DiscourseRatings::Cache.new("#{KEY}_list").delete
  end

  def self.get_name(type)
    if (rating_type = cached_list.select { |rt| rt.type === type }).present?
      rating_type.first.name
    end
  end

  def self.exists?(type)
    return true if type == NONE
    PluginStoreRow.where(
      "
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key = ?
    ",
      build_key(type),
    ).exists?
  end

  def self.create(type, name)
    ## none type can only be set via bulk operation
    ## 'count' is a legacy type from 0.2. Remove 'count' exception in early 2021
    return false if [NONE, "count"].include?(type)

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
    key.split("_", 2).last
  end
end

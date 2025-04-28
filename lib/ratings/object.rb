# frozen_string_literal: true
class DiscourseRatings::Object
  include ActiveModel::SerializerSupport

  TYPES ||= %w[category tag]

  attr_accessor :name, :types

  def initialize(name, types)
    @name = name
    @types = types
  end

  def self.list(object_type)
    PluginStoreRow
      .where(
        "
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{object_type}_%'
    ",
      )
      .map { |r| new(name_from_key(r.key), types_from_value(r.value)) }
  end

  def self.exists?(object_type, name)
    PluginStoreRow.where(
      "
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key = ?
    ",
      build_key(object_type, name),
    ).exists?
  end

  def self.create(object_type, name, types)
    if exists?(object_type, name) || object_type.blank? || name.blank? || types.blank?
      false
    else
      set(object_type, name, types)
    end
  end

  def self.get(object_type, name)
    if (
         value = PluginStore.get(DiscourseRatings::PLUGIN_NAME, build_key(object_type, name))
       ).present?
      types_from_value(value)
    else
      []
    end
  end

  def self.set(object_type, name, types)
    if TYPES.include?(object_type)
      PluginStore.set(
        DiscourseRatings::PLUGIN_NAME,
        build_key(object_type, name),
        build_value(types),
      )
    end
  end

  def self.destroy(object_type, name)
    PluginStore.remove(DiscourseRatings::PLUGIN_NAME, build_key(object_type, name))
  end

  def self.remove_type(object_type, rating_type)
    PluginStoreRow
      .where(
        "
      plugin_name = '#{DiscourseRatings::PLUGIN_NAME}' AND
      key LIKE '#{object_type}_%'
    ",
      )
      .each do |r|
        types = types_from_value(r.value).select { |t| t != rating_type }

        if types.any?
          r.value = build_value(types)
          r.save
        else
          r.destroy
        end
      end
  end

  def self.build_key(object_type, name)
    "#{object_type}_#{name}"
  end

  def self.name_from_key(key)
    key.split("_", 2).last
  end

  def self.types_from_value(value)
    value.split("|")
  end

  def self.build_value(types)
    types.join("|")
  end
end

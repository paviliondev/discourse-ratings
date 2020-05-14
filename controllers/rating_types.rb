class DiscourseRatings::RatingTypesController < ::ApplicationController
  def add
    params.require(:type_name)
    type = PluginStore.new('rating_type')
    type.set(Slug.for(params[:type_name]), params[:type_name])
    render_json_dump(success_json)
  end

  def update
    params.require(:type_id)
    type = PluginStoreRow.find(params[:type_id])
    type[:type_name] = params[:type_name]
    type.save
    render_json_dump(success_json)
  end

  def list
    listing = PluginStoreRow.where(plugin_name: 'rating_type')
    listing = [listing] if listing.is_a? Hash
    render_json_dump(listing)
  end

  def destroy
    params.require(:type_id)
    PluginStoreRow.destroy(params[:type_id])
    render_json_dump(success_json)
  end
end

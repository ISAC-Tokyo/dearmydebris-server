class Api::V1::DebrisController < ApplicationController

  after_filter :set_access_control_headers
  respond_to :json
  def index
    debris = Debris.limit(1000)
    res_geojson =
      {
      :type => "FeatureCollection",
      :feature => debris.map(&:get_hash)
    }.as_json
    respond_with res_geojson
  end

  def all
    debris = Debris.all
    res_geojson =
      {
      :type => "FeatureCollection",
      :feature => debris.map(&:get_hash)
    }.as_json
    respond_with res_geojson
  end

  def show
    debris = Debris.find(params[:id])
    res_geojson =
      {
      :type => "FeatureCollection",
      :feature => debris.get_hash
    }.as_json
    respond_with res_geojson
  end

  def edit
  end

  def catalogs
    nssdc_catalog = NssdcCatalog.where(cid: params[:cid]).first
    debrises = nssdc_catalog.debrises
    res_geojson =
      {
      :type => "FeatureCollection",
      :feature => debrises.map(&:get_hash)
    }.as_json
    respond_with res_geojson
  end

  def show_all_user
    user = User.all
    res_userjson =
      {
      :type => "FeatureCollection",
      :feature => user.map(&:get_hash)
    }.as_json
    respond_with res_userjson
  end

  def show_user
    user = User.where(facebook_id: params[:facebook_id]).first
    res_userjson =
      {
      :type => "FeatureCollection",
      :feature => user.get_hash
    }.as_json
    respond_with res_userjson
  end

  def add_follower
    debris = Debris.find(params[:id])
    follower = User.where(facebook_id: params[:facebook_id]).first
    debris.users.push follower
    debris.save
  end

  def remove_follower
    debris = Debris.find(params[:id])
    follower = User.where(facebook_id: params[:facebook_id]).first
    debris.users.delete follower
  end

  def follow_debris
    debris = Debris.find(params[:id])
    follower = User.where(facebook_id: params[:facebook_id]).first
    follower.debrises.push debris
    follower.save
  end

  def unfollow_debris
    debris = Debris.find(params[:id])
    follower = User.where(facebook_id: params[:facebook_id]).first
    follower.debrises.delete debris
  end

  private
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end
end

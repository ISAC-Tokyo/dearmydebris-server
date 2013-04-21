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

  def show
  end

  def edit
  end

  def add_follower
    id, follower = params[ :id ], params[ :follower ]
    debris = Debris.find(id)

    debris.follower.push follower
    debris.save
  end

  def remove_follower
    id, follower = params[ :id ], params[ :name ]
    debris = Debris.find(id)

    debris.follower.delete_if{ |x| x == follower }
    debris.save
  end

  private
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end
end

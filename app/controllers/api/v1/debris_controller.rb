class Api::V1::DebrisController < ApplicationController

  after_filter :set_access_control_headers
  respond_to :json
  def index
     res_geojson =
    {
      :type => "FeatureCollection",
      :feature => [{
        :type => "Feature",
        :geometry => {
          :type => "Point",
          :coordinates => [ 139.67768669128418, 35.66193375685752, 100000 ]
        },
        :properties => {
          :name => "VANGUARD 1",
          :id => "1",
          :follower => [ "osoken", "smellman" ]
        }
      },
        {:type => "Feature",
        :geometry => {
          :type => "Point",
          :coordinates => [ 139.67768669128418, 35.66193375685752, 120000 ]
        },
        :properties => {
          :name => "VANGUARD 1",
          :id => "2",
          :follower => [ "tacke-yuuki","tree4-s","jumbo","taka.aom" ]
        }
      }]
    }.as_json
    respond_with res_geojson
  end

  def show
  end

  def edit
  end

  private
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end
end

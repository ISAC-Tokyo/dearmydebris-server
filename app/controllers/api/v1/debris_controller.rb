class Api::V1::DebrisController < ApplicationController
  respond_to :json
  def index
     res_geojson =
    {
      :type => "FeatureCollection",
      :feature => [{
        :type => "Feature",
        :geometry => {
          :type => "Point",
          :coordinates => [ 10, 50, 10000 ]
        },
        :properties => {
          :name => "VANGUARD",
          :id => "hogehoge",
          :follower => [ "osoken", "smellman" ]
        }
      }]
    }.as_json
    respond_with res_geojson
  end

  def show
  end

  def edit
  end
end

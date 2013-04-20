class Api::V1::DebrisController < ApplicationController
  respond_to :json
  def index
    res = { :latitude => 0, :longnitude => 90, :name => "hoge" }.as_json
    respond_with res
  end

  def show
  end

  def edit
  end
end

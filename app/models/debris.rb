require 'tle'

class Debris
  include Mongoid::Document
  field :catalog_no_1, :type => String
  field :security_classification, :type => String
  field :international_identification, :type => Integer
  field :epoch_year, :type => Integer
  field :epoch, :type => String
  field :first_derivative_mean_motion, :type => Integer
  field :second_derivative_mean_motion , :type => Float
  field :bstar_mantissa, :type => Float
  field :bstar_exponent, :type => Float
  field :bstar, :type => Float
  field :ephemeris_type, :type => Integer
  field :element_number, :type => Integer
  field :check_sum_1, :type => Integer

  field :catalog_no_2, :type => Integer
  field :inclination, :type => Float
  field :right_ascension, :type => Float
  field :eccentricity, :type => Integer
  field :argument_of_perigee, :type => Float
  field :mean_anomaly, :type => Float
  field :mean_motion, :type => Float
  field :rev_number_at_epoch, :type => Integer
  field :check_sum_2, :type => Integer

  field :follower, :type => Array

  field :name, :type => String
  field :first_line, :type => String
  field :second_line, :type => String

  def geographic(time)
    satrec = Tle::Elements.new(self.first_line, self.second_line, Tle::WGS72)
    r, v = satrec.sgp4(time, Tle::WGS72)
    xkm = r[0]
    ykm = r[1]
    zkm = r[2]
    xdotkmps = v[0]
    ydotkmps = v[1]
    zdotkmps = v[2]
    rad = Math::PI / 180
    gmst = time.gmst()
    lst = gmst*15
    f =  0.00335277945
    a =  6378.135 
    r = Math.sqrt(xkm * xkm + ykm * ykm)
    lng = Math.atan2(ykm, xkm) / rad - lst
    if lng > 360
      lng = lng % 360
    end
    if lng < 0
      lng = lng % 360 + 360
    end
    if lng > 180
      lng = lng - 360
    end
    lat = Math.atan2(zkm, r)
    e2 = f * (2 - f)
    tmp_lat = 0
    
    while ((lat - tmp_lat).abs > 0.0001) do
      tmp_lat = lat
      sin_lat = Math.sin(tmp_lat)
      c = 1 / Math.sqrt(1 - e2 * sin_lat * sin_lat)
      lat = Math.atan2(zkm + a * c * e2 * (Math.sin(tmp_lat)), r);
    end
    alt = r / Math.cos(lat) - a * c
    v = Math.sqrt(xdotkmps * xdotkmps + ydotkmps * ydotkmps + zdotkmps * zdotkmps)
    return {
      :longitude => lng,
      :latitude => lat / rad,
      :altitude => alt,
      :velocity => v
    }
    
  end

  private

  def _gmst
  end

end

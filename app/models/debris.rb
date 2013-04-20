require 'tle'

class Debris
  include Mongoid::Document

  field :name, :type => String
  field :first_line, :type => String
  field :second_line, :type => String

  field :catalog_no_1, :type => Integer
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
  field :category, :type => String

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

      tmp_lat = lat
      sin_lat = Math.sin(tmp_lat)
      c = 1 / Math.sqrt(1 - e2 * sin_lat * sin_lat)
      lat = Math.atan2(zkm + a * c * e2 * (Math.sin(tmp_lat)), r);
    
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

  def self.load_from_file(file_path)

    f = open(file_path)
    d = nil
    count = 0
    f.each {|line|
      case count % 3
      when 0
        d = Debris.new
        d.name = line.chomp
      when 1
        d.first_line = line.chomp

        d.catalog_no_1 = line.slice(2,5).to_i
        d.id = d.catalog_no_1
        d.security_classification = line.slice(7,1)
        d.international_identification = line.slice(9,2).to_i
        epy = line.slice(11,3).to_i
        if epy < 57 then d.epoch_year = epy + 2000 else d.epoch_year = epy + 1900 end
        d.epoch = line.slice(14,3)
        d.first_derivative_mean_motion = line.slice(18,2).to_i
        d.second_derivative_mean_motion = line.slice(20,12).to_f
        d.bstar_mantissa = line.slice(33,10).to_f
        d.bstar_exponent = parse_float(line.slice(44,8))
        d.bstar = parse_float(line.slice(53,8))
        d.ephemeris_type = line.slice(62,1).to_i
        d.element_number = line.slice(64,4).to_i
        d.check_sum_1 = line.slice(68,1).to_i

      when 2
        d.second_line = line.chomp

        d.catalog_no_2 = line.slice(2,5).to_i
        d.inclination = line.slice(8,8).to_f
        d.right_ascension = line.slice(17,8).to_f
        d.eccentricity = line.slice(26,7).to_i
        d.argument_of_perigee = line.slice(34,8).to_f
        d.mean_anomaly = line.slice(43,8).to_f
        d.mean_motion = line.slice(52,11).to_f
        d.rev_number_at_epoch = line.slice(63,5).to_i
        d.check_sum_2 = line.slice(68,1).to_i

        d.save
      end
      count = count + 1
    }
    f.close
    puts "finish"
  end

  def self.parse_float(str)
    mantissa, exponent = str.split("-")
    return mantissa.to_f * (10 ** exponent.to_i)
  end



end

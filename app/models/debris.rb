require 'tle'
require 'nokogiri'
require 'open-uri'
require 'scanf'

class Debris
  include Mongoid::Document

  field :name, :type => String
  field :first_line, :type => String
  field :second_line, :type => String

  field :catalog_no_1, :type => Integer
  field :security_classification, :type => String
  field :epoch_year, :type => Integer
  field :nssdcid_1, :type => Integer
  field :nssdcid_2, :type => String
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

  field :latitude, :type => Float
  field :longitude, :type => Float
  field :altitude, :type => Float

  belongs_to :nssdc_catalog, class_name: "NssdcCatalog"

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

  def get_hash
    geographic = self.geographic(DateTime.now)
    #nssdc = NssdcCatalog.where(:cid => self.cid).first
    return {
      :type => "Feature",
      :geometry => {
        :type => "Point",
        :coordinates => [geographic[:longitude], geographic[:latitude], geographic[:altitude]]
      },
      :properties => {
        :name => self.name,
        :id => self._id,
        :follower => ["osoken", "smellman"],
        :nssdc_catalog => self.nssdc_catalog,
        :category => get_category
      }
    }
  end

  def set_latlon
    geographic = self.geographic(DateTime.now)
    self.latitude = geographic[:latitude]
    self.longitude = geographic[:longitude]
    if geographic[:altitude] < 0
      self.altitude = 0
    else
      self.altitude = geographic[:altitude]
    end
  end

  def get_category
    if self.name.include?("R/B")
      return "RB"
    elsif self.name.include?("DEB")
      return "DEB"
    else
      return nil
    end
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
        d.security_classification = line.slice(7,1)
        epy = line.slice(9,2).to_i
        if epy < 57 then d.epoch_year = epy + 2000 else d.epoch_year = epy + 1900 end
        d.nssdcid_1 = line.slice(11,3).to_i
        d.nssdcid_2 = line.slice(14,3).strip
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

  def cid
    return "" if self.nssdcid_1.nil?
    tmp_id = "%03d" % self.nssdcid_1
    "#{self.epoch_year}-#{tmp_id}A"
  end

  def self.get_same_cid(cid)
    epoch_year, nssdcid_1 = cid.scanf("%4d-%03dA")
    return self.where(epoch_year: epoch_year).where(nssdcid_1: nssdcid_1)
  end

  def self.update_latlon
    Debris.all.each do |x|
      x.set_latlon
      x.save
    end
  end

  def self.crawler
    Debris.all.map(&:cid).uniq.each do |x|
      international_identification = "#{x}"
      page = open("http://nssdc.gsfc.nasa.gov/nmc/spacecraftDisplay.do?id=#{international_identification}")
      doc = Nokogiri::HTML(page.read, nil, 'UTF-8')
      doc_item_p = doc.search('//div[@class="urone"]')
      n = NssdcCatalog.new
      n.cid = x
      n.description = ""
      unless doc_item_p.nil?
        doc_item_p.search('p').each do |content|
          n.description = content.text
        end
        n.description = n.description.strip unless n.description.blank?
        doc_item_href = doc.search('//div[@class="capleft"]')
        unless doc_item_href.nil?
          doc_item_href.search("a").each do |alink|
            n.img = alink.attribute("href")
          end
        end
      end
      n.save
      Debris.get_same_cid(x).each do |d|
        d.nssdc_catalog = n
        d.save
      end
    end
  end

  def self.collect_debris

  end

end

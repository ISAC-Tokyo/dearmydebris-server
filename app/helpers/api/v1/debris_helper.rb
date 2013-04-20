module Api::V1::DebrisHelper

  def load_from_file()

    f = open(File.expand_path(File.dirname(__FILE__)) + "/all.txt")
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

  def parse_float(str)
    mantissa, exponent = str.split("-")
    return mantissa.to_f * (10 ** exponent.to_i)
  end

end

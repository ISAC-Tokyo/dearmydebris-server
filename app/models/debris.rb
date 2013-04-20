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
end

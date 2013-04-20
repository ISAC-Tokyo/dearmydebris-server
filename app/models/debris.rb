class Debris
  include Mongoid::Document
  field :name, :type => String
  field :first_line, :type => String
  field :second_line, :type => String
end

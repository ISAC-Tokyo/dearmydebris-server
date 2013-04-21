class NssdcCatalog
  include Mongoid::Document
  field :cid, :type => String
  field :img, :type => String
  field :description, :type => String

end

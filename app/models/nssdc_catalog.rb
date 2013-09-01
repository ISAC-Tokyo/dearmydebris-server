class NssdcCatalog
  include Mongoid::Document
  field :cid, :type => String
  field :img, :type => String
  field :description, :type => String

  has_many :debrises, class_name: "Debris"

  def get_hash
    return {
      :cid => self.cid,
      :img => self.img,
      :description => self.description
    }
  end
end

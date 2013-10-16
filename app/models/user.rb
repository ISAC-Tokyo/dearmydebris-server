class User
  include Mongoid::Document

  field :facebook_id, :type => Integer
  field :user_name, :type => String
  field :icon_url, :type => String
  field :oath_token, :type => String

  has_and_belongs_to_many :debrises, class_name: "Debris"

  def get_hash
    return {
      :facebook_id => self.facebook_id,
      :user_name => self.user_name,
      :icon_url => self.icon_url,
      :oath_token => self.oath_token
    }
  end
end

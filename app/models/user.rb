class User
  include Mongoid::Document
  field :privider, type: String
  field :uid, type: String
  field :name, type: String
  
  def self.create_with_omniauth(auth)
    create!do |user|
     user.provider = auth["provider"]
     user.uid = auth["uid"]

     if user.provider == "facebook"
       user.name = auth["info"]["name"]
     else
       user.name = auth["info"]["nickname"]
     end
    end
  end
end

class Eve::Region < ActiveRecord::Base
  include IdentityCache

  property :name,            type: :string 

  has_many :solar_system

end
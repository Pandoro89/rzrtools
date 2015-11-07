class Eve::SolarSystem < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  
  property :region_id,            type: :integer 
  property :constellation_id,            type: :integer 
  property :name,            type: :string 
  property :x,            type: :integer , :limit => 8
  property :y,            type: :integer , :limit => 8
  property :z,            type: :integer , :limit => 8
  property :border,            type: :integer
  property :fringe,            type: :integer 
  property :corridor,            type: :integer
  property :hub,            type: :integer
  property :regional,            type: :integer
  property :security,            type: :float

  belongs_to :region
end
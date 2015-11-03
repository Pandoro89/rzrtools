class Eve::SolarSystemJump < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  
  property :from_region_id,            type: :integer 
  property :from_constellation_id,            type: :integer 
  property :from_solar_system_id,            type: :integer 
  property :to_region_id,            type: :integer 
  property :to_constellation_id,            type: :integer 
  property :to_solar_system_id,            type: :integer 


end
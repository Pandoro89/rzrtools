class Eve::InvType < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  
  property :eve_group_id,            type: :integer , limit: 8
  property :name,            type: :string, limit: 255 
  property :description,            type: :string 
  property :mass,            type: :integer, limit: 8 
  property :volume,            type: :integer , limit: 8
  property :capacity,            type: :integer , limit: 8
  property :portion_size,            type: :integer , limit: 8
  property :published,            type: :integer
  property :icon_id,            type: :integer 
  # GROUPID TYPENAME  DESCRIPTION MASS  VOLUME  CAPACITY  PORTIONSIZE RACEID  BASEPRICE PUBLISHED MARKETGROUPID ICONID  SOUNDID


end
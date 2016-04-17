class ScanResult < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :scan_id,       type: :integer
  property :scan_type,          type: :string, limit: 50, default: "Local"
  property :character_id,       type: :integer, default: "0"
  property :char_name,          type: :string, limit: 250
  property :alliance_id,        type: :integer, default: "0"
  property :corp_name,          type: :string, limit: 255, default: ""
  property :corporation_id,     type: :integer, limit: 8 , default: "0"
  property :alliance_name,      type: :string, limit: 255, default: ""
  property :alliance_id,        type: :integer, limit: 8 , default: "0"
  property :solar_system_id,    type: :integer, limit: 8 , default: "0"
  property :solar_system_name,  type: :string, limit: 255, default: ""
  property :item_type_id,       type: :integer, limit: 8 , default: "0"
  property :item_type_name,     type: :string, limit: 255, default: ""
  property :item_group_id,      type: :integer, limit: 8 , default: "0"
  property :item_group_name,    type: :string, limit: 255, default: ""
  property :eve_category_id,    type: :integer, limit: 8 , default: "0"
  property :distance,           type: :integer, limit: 8 , default: "0"
  property :fleet_role,    type: :string, limit: 255, default: ""
  property :fleet_skills,    type: :string, limit: 255, default: ""
  property :fleet_position,    type: :string, limit: 255, default: ""

  timestamps

end

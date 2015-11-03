class Watchlist < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :char_id,            type: :integer, limit: 8, default: "0" 
  property :char_name,          type: :string, limit: 255, default: ""
  property :corp_id,            type: :integer,limit: 8, default: "0" 
  property :corp_name,          type: :string, limit: 255, default: ""
  property :alliance_name,      type: :string, limit: 255, default: ""
  property :alliance_id,            type: :integer,limit: 8, default: "0" 
  property :solar_system_name,  type: :string, limit: 255, default: ""
  property :solar_system_id,            type: :integer,limit: 8, default: "0" 
  property :ship_type_name,     type: :string, limit: 255, default: ""
  property :ship_type_id,            type: :integer,limit: 8, default: "0" 
  property :last_seen_at,            type: :datetime
  timestamps
end
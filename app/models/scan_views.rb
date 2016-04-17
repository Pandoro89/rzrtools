class ScanView < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :scan_id,       type: :integer
  property :last_ip,       type: :string, limit: 50
  property :character_id,  type: :integer, limit: 8 , default: "0"
  property :char_name,     type: :string, limit: 250
  timestamps

end
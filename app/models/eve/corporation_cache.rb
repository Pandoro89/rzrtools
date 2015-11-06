class Eve::CorporationCache < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :name,            type: :string, limit: 255 
  property :ticker,            type: :string, limit: 50
  property :razor_ticker,            type: :string, limit: 50 
  timestamps

  def self.add_or_update(id, name)
    return if name.nil?
    a = self.find_or_create_by(id: id)
    a.name = name
    a.save
  end
  
end
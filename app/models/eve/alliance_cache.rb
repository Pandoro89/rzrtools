class Eve::AllianceCache < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :name,            type: :string, limit: 255 


  timestamps

  def self.add_or_update(id, name)
    return if name.nil?
    a = self.find_or_create_by(id: id)
    a.name = name
    a.save
  end
  
end
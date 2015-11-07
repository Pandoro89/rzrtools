class Eve::CorporationCache < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :name,            type: :string, limit: 255 
  property :ticker,            type: :string, limit: 50
  property :razor_ticker,            type: :string, limit: 50 
  property :alliance_id,            type: :integer
  property :member_count,         type: :integer
  timestamps

  belongs_to :alliance, :class_name => "Eve::AllianceCache"

  def self.add_or_update(id, name)
    return if name.nil?
    a = self.find_or_create_by(id: id)
    a.name = name
    a.save
  end

  def self.update_from_api(id)
    api = EAAL::API.new("", "")
    api.scope = "corp"
    result = api.CorporationSheet(:corporationID => id)
    c = self.find_or_create_by(id: id)
    c.alliance_id = result.allianceID
    c.ticker = result.ticker
    c.member_count = result.memberCount
    c.save
    Eve::AllianceCache.add_or_update(result.allianceID, result.allianceName)
  end
  
end
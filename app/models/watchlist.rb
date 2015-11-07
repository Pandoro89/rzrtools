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
  property :deleted_at,                    type: :datetime
  property :wl_type,               type: :integer, default: "1" # 1 = Ship, 2 = FC
  property :z_kill_id,            type: :integer,limit: 8
  property :comment,            type: :text
  timestamps
  acts_as_paranoid

  belongs_to :solar_system, :class_name => "Eve::SolarSystem"

  def wl_type_to_s
    return "FC" if wl_type == 2
    "Ship"
  end

  def self.import_zkillboard
    @ship_type_ids = Eve::InvType.where("eve_group_id = 659 OR eve_group_id = 30").collect{|inv| inv.id}
    @ship_type_ids_s = @ship_type_ids.join(",")
    year = Time.now.strftime("%Y")
    response = HTTParty.get("https://zkillboard.com/api/kills/shipID/#{@ship_type_ids_s}/year/#{year}/no-items/orderDirection/desc/")
    results = response.parsed_response
    Watchlist.process_results(results)

    char_ids = Watchlist.where(:wl_type => 2).collect { |w| w.char_id }.reject { |a| a.nil? }.join(",")
    return if char_ids.nil? or char_ids == ""
    response = HTTParty.get("https://zkillboard.com/api/kills/characterID/#{char_ids}/year/#{year}/no-items/orderDirection/desc/")
    results = response.parsed_response
    Watchlist.process_results(results)    
  end

  def self.process_results(results)
    results.each { |r|
      if @ship_type_ids.include? r['victim']['shipTypeID']
        w = Watchlist.where(:char_id => r['victim']['characterID']).first
        w = Watchlist.create(:char_id => r['victim']['characterID'], :char_name => r['victim']['characterName']) if w.nil?
        w.corp_id = r['victim']['corporationID']
        w.corp_name = r['victim']['corporationName']
        w.alliance_id = r['victim']['allianceID']
        w.alliance_name = r['victim']['allianceName']
        w.ship_type_id = r['victim']['shipTypeID']
        w.solar_system_id = r['solarSystemID']
        w.last_seen_at = DateTime.parse(r['killTime'])
        w.ship_type_name = Eve::InvType.find(r['victim']['shipTypeID']).name
        w.solar_system_name = Eve::SolarSystem.find(r['solarSystemID']).name
        w.z_kill_id = r['killID']
        Eve::CorporationCache.add_or_update(w.corp_id, w.corp_name)
        Eve::AllianceCache.add_or_update(w.alliance_id, w.alliance_name) if !w.alliance_name.nil?
        w.save
      end

      r['attackers'].each { |a|
        if @ship_type_ids.include? a['shipTypeID']
          w = Watchlist.where(:char_id => a['characterID']).first
          w = Watchlist.create(:char_id => a['characterID'], :char_name => a['characterName']) if w.nil?
          w.corp_id = a['corporationID']
          w.corp_name = a['corporationName']
          w.alliance_id = a['allianceID']
          w.alliance_name = a['allianceName']
          w.ship_type_id = a['shipTypeID']
          w.solar_system_id = r['solarSystemID']
          w.last_seen_at = DateTime.parse(r['killTime'])
          w.ship_type_name = Eve::InvType.find(a['shipTypeID']).name
          w.solar_system_name = Eve::SolarSystem.find(r['solarSystemID']).name
          w.z_kill_id = r['killID']
          Eve::CorporationCache.add_or_update(w.corp_id, w.corp_name)
          Eve::AllianceCache.add_or_update(w.alliance_id, w.alliance_name) if !w.alliance_name.nil?
          w.save
        end
      }

    }
  end

end
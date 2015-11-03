class ImportZkillboardWatchlistJob < Resque::Job
  @queue = :low

  def self.perform()
    # Supers: SELECT * FROM inv_types WHERE eve_group_id = 659
    # Titans: SELECT * FROM inv_types WHERE eve_group_id = 30
    # https://zkillboard.com/api/kills/shipID/644,638/orderDirection/asc/
    ship_type_ids = Eve::InvType.where("eve_group_id = 659 OR eve_group_id = 30").collect{|inv| inv.id}
    ship_type_ids_s = ship_type_ids.join(",")
    year = Time.now.strftime("%Y")
    response = HTTParty.get("https://zkillboard.com/api/kills/shipID/#{ship_type_ids_s}/year/#{year}/no-items/orderDirection/desc/")
    results = response.parsed_response
    results.each { |r|
      if ship_type_ids.include? r['victim']['shipTypeID']
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
        Eve::CorporationCache.add_or_update(w.corp_id, w.corp_name)
        Eve::AllianceCache.add_or_update(w.alliance_id, w.alliance_name)
        w.save
      end

      r['attackers'].each { |a|
        if ship_type_ids.include? a['shipTypeID']
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
          Eve::CorporationCache.add_or_update(w.corp_id, w.corp_name)
          Eve::AllianceCache.add_or_update(w.alliance_id, w.alliance_name)
          w.save
        end
      }

    }
  end

end
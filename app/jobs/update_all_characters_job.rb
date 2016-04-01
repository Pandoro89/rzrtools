class UpdateAllCharactersJob < Resque::Job
  @queue = :high

  def self.perform
    api = EAAL::API.new("", "")
    api.scope = "eve"
    Character.all.each do |row|
      begin
      result = api.CharacterID(:names => row.char_name)
      result.characters.each {|c|
        char = Character.find_or_create_by(:id => c.characterID)
        char.char_name = c.name
        char.save
        result2 = nil
        result2 = api.CharacterInfo(:characterID => char.id)
        next if result2.nil?
        char.corporation_id = result2.corporationID
        char.corp_name = result2.corporation
        begin
          char.alliance_id = result2.allianceID if result2.allianceID
          char.alliance_name = result2.alliance if result2.alliance
          Eve::AllianceCache.add_or_update(result2.allianceID,result2.alliance) if result2.allianceID and !result2.alliance.nil?
        rescue NoMethodError
          # NOOP
        end
        char.save
        Eve::CorporationCache.add_or_update(result2.corporationID,result2.corporation) if result2.corporationID
        FleetPosition.where(:char_name => name).update_all(:character_id => char.id)
      }
    rescue EveAPIException105
      #noop
    end
    end

  end

end
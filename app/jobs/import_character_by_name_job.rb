class ImportCharacterByNameJob < Resque::Job
  @queue = :medium

  def self.perform(name)
    api = EAAL::API.new("", "")
    api.scope = "eve"
    result = api.CharacterID(:names => name)
    result.characters.each {|c|
      char = Character.find_or_create_by(:id => c.characterID)
      char.char_name = c.name
      char.save
      result2 = api.CharacterInfo(:characterID => char.id)
      char.corporation_id = result2.corporationID
      char.corp_name = result2.corporation
      begin
        char.alliance_id = result2.allianceID if result2.allianceID
        char.alliance_name = result2.alliance if result2.alliance
        Eve::AllianceCache.add_or_update(result2.allianceID,result2.alliance) if result2.allianceID
      rescue NoMethodError
        # NOOP
      end
      char.save
      Eve::CorporationCache.add_or_update(result2.corporationID,result2.corporation) if result2.corporationID
      FleetPosition.where(:char_name => name).update_all(:character_id => char.id)
    }
  end

  def self.migrate_pap_chars
    FleetPosition.all.each {|fp| Resque.enqueue ImportCharacterByNameJob, fp.char_name if fp.character_id == 0}
  end

end 
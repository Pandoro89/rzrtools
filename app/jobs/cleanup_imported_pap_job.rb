class CleanupImportedPapJob < Resque::Job
  @queue = :low

  def self.perform()
    FleetPosition.where(:character_id => 0).each { |fp|
      Resque.enqueue ImportCharacterByNameJob, fp.char_name
    }
    FleetPosition.where(:corporation_id => 0).each {|fp|
      @corp = Eve::CorporationCache.where(:name => fp.corp_name).first
      if @corp 
        fp.update_attributes(:corporation_id => @corp.id)
      else
        # TODO, fetch?
      end
    }
    FleetPosition.where(:ship_type_id => 0).each {|fp|
      @item = Eve::InvType.where(:name => fp.ship_type_name).first
      if @item 
        fp.update_attributes(:ship_type_id => @item.id)
      else
        # TODO, fetch?
      end
    }
    FleetPosition.where(:ship_group_id => 0).each {|fp|
      @item = Eve::Group.where(:name => fp.ship_group_name).first if !fp.ship_group_name.nil? and fp.ship_group_name != ""
      @item ||= Eve::InvType.where(:id => fp.ship_type_id).first.try(:eve_group)
      if @item 
        fp.update_attributes(:ship_group_id => @item.id, :ship_group_name => @item.name)
      else
        # TODO, fetch?
      end
    }

    api = EAAL::API.new("", "")
    api.scope = "eve"
    Character.where(:corporation_id => 0).each {|char|
      begin
        result2 = api.CharacterInfo(:characterID => char.id)
      rescue EveAPIException522
        # is this safe? char.delete
        next
      end
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
      FleetPosition.where(:char_name => char.char_name).update_all(:character_id => char.id)
    }
  end
end
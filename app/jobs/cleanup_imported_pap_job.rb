class CleanupImportedPapJob < Resque::Job
  @queue = :high

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
      @item = Eve::Group.where(:name => fp.ship_group_name).first
      if @item 
        fp.update_attributes(:ship_group_id => @item.id)
      else
        # TODO, fetch?
      end
    }
  end
end
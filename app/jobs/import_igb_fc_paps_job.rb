class ImportIgbFcPapsJob < Resque::Job
  @queue = :low 

  def self.perform(file)
    # static/pap/a/741557221/current.csv
    if file.nil?
      file = "members_fc_current.csv"
    end
    response = HTTParty.get("http://apps.eve-razor.com/static/pap/a/741557221/#{file}")
    @razor = Eve::AllianceCache.find(ALLIANCE_ID)
    csv = CSV.parse(response.body, :headers=>true)
    @fleet = nil
    csv.each do |row|
      puts row
      when_date = row[8].split("/")
      fleet_at = DateTime.parse(when_date[2]+"-"+when_date[0]+"-"+when_date[1] +" " + row[9])
      joined_at = DateTime.parse(when_date[2]+"-"+when_date[0]+"-"+when_date[1] +" " + row[9])
      @fleet = Fleet.where("description = ? AND created_at >= ? AND created_at <= ?",row[3], fleet_at - 2.hours, fleet_at + 2.hours).first
      if @fleet.nil?
        @fleet = Fleet.create(:description => row[3], :fleet_at => fleet_at)
      end
      @fleet.created_at = fleet_at
      @fleet.fleet_at = fleet_at
      @fleet.close_at = fleet_at
      @fleet.status = 1
      #@fleet.modified_at = fleet_at
      @fleet.save
      @pap = FleetPosition.find_or_create_by(:char_name => row[0], :fleet_id => @fleet.id)
      @char = Character.where(:char_name => @pap.char_name).first
      if @char.nil?
        Resque.enqueue ImportCharacterByNameJob, @pap.char_name
      end
      @pap.character_id = @char.id if !@char.nil?
      @pap.created_at = fleet_at
      @pap.main_name = row[1]
      @pap.main_name = @char.main_name if @char and (@pap.main_name.nil? or @pap.main_name == "")
      @pap.main_name = nil if @pap.main_name == ""
      @pap.special_role = row[5]
      @pap.ship_type_name = row[6]
      @ship_item = Eve::InvType.where(:name => @pap.ship_type_name).first
      @pap.ship_type_id = @ship_item.id if !@ship_item.nil?
      @pap.ship_group_name = row[7]
      @ship_group = Eve::Group.where(:name => @pap.ship_group_name).first
      @pap.ship_group_id = @ship_group.id if !@ship_group.nil?
      @pap.corp_name = row[2]
      @pap.alliance_id = ALLIANCE_ID
      @pap.alliance_name = @razor.name
      @pap.save
      
      # Mandudes Personal Jukebox, cartruce, 0:45, ts op 1
      # svipuls, amiran omanid, 18:21, ts op 1
      fleet_split = @fleet.description.split(",")
      if fleet_split.size == 4
        @fleet.fleet_name = fleet_split[0].strip
        @fleet.fc_name = fleet_split[1].strip
        @fleet.fleet_time = fleet_split[2].strip
        @fleet.fleet_coms = fleet_split[3].strip
        @fleet.save
      end

    end
  end

end
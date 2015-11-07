class ImportIgbPapsJob < Resque::Job
  @queue = :low 

  def self.perform(file)
    # static/pap/a/741557221/current.csv
    if file.nil?
      file = "members_current.csv"
    end
    response = HTTParty.get("http://apps.eve-razor.com/static/pap/a/741557221/#{file}")
    @razor = Eve::AllianceCache.find(ALLIANCE_ID)
    csv = CSV.parse(response.body, :headers=>true)
    @fleet = nil
    csv.each do |row|
      puts row
      when_date = row[6].split("/")
      fleet_at = DateTime.parse(when_date[2]+"-"+when_date[0]+"-"+when_date[1] +" " + row[7])
      @fleet = Fleet.find_or_create_by(:description => row[3], :fleet_at =>fleet_at) if @fleet.nil? or @fleet.description != row["Fleet"]
      @fleet.created_at = fleet_at
      #@fleet.modified_at = fleet_at
      @fleet.save
      @pap = FleetPosition.find_or_create_by(:char_name => row[0], :fleet_id => @fleet.id)
      @pap.main_name = row[1]
      @pap.ship_type_name = row[4]
      @ship_item = Eve::InvType.where(:name => @pap.ship_type_name).first
      @pap.ship_type_id = @ship_item.id if !@ship_item.nil?
      @pap.ship_group_name = row[5]
      @ship_group = Eve::Group.where(:name => @pap.ship_group_name).first
      @pap.ship_group_id = @ship_group.id if !@ship_group.nil?
      @pap.corp_name = row[2]
      @pap.corporation_id = Eve::CorporationCache.where(:name => @pap.corp_name).first.try(:id)
      @pap.alliance_id = ALLIANCE_ID
      @pap.alliance_name = @razor.name
      @pap.save
      
    end
  end

end
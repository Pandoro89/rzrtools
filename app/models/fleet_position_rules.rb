class FleetPositionRules < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

    property :eve_group_id,       type: :integer, default: "0"
    property :ship_type_id,       type: :integer, default: "0"
    property :fleet_role,         type: :string, limit: 255, default: "Other" #as: "ENUM('Other','Fleet','Logistics','Command_Ship','Black_Ops','Capital','Super.Titan')"
    property :special_role,       type: :string, limit: 255, default: "none"  #as: "ENUM('none','FC','Co-FC','Logi_FC','Scout','Prober','Target_Caller')"
    property :points,             type: :integer, default: "1"


    def self.apply_rules_to_fleets
      Fleet.where("created_at > ?", DateTime.now-1.hour).each { |f| 
        f.fleet_positions.each {|fp| FleetPositionRules.apply_rules(fp) }
      }
    end


    def self.apply_rules(fleet_position_id)
      pap = FleetPosition.find(fleet_position_id)
      logger.debug("----- #{fleet_position_id}")
      return if pap.nil?

      where("1=1", pap.ship_type_id).each { |r| 
        if r.eve_group_id == Eve::InvType.where(:id => pap.ship_type_id).first.eve_group_id
          pap.fleet_role = r.fleet_role
          pap.points = r.points
        elsif r.ship_type_id == pap.ship_type_id
           pap.fleet_role = r.fleet_role
           pap.points = r.points
        end

      }

      pap.save
    end
end
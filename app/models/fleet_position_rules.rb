class FleetPositionRules < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

    property :eve_group_id,            type: :integer, default: "0"
    property :ship_type_id,       type: :integer, default: "0"
    property :fleet_role,         type: :string, limit: 255, default: "Other" #as: "ENUM('Other','Fleet','Logistics','Command_Ship','Black_Ops','Capital','Super.Titan')"
    property :special_role,       type: :string, limit: 255, default: "none"  #as: "ENUM('none','FC','Co-FC','Logi_FC','Scout','Prober','Target_Caller')"

    def self.apply_rules_to_fleets
      Fleet.where("created_at > ?", DateTime.now-1.hour).each { |f| 
        FleetPositionRules.apply_rules(f)
      }
    end

    def self.apply_rules(fleet)
      fleet.fleet_positions
    end

    def self.apply_rules(fleet_position_id)
      pap = FleetPosition.find(fleet_position_id)
      logger.debug("----- #{fleet_position_id}")
      return if pap.nil?

      where("1=1", pap.ship_type_id).each { |r| 
        pap.fleet_role = r.fleet_role if r.eve_group_id == Eve::InvType.where(:id => pap.ship_type_id).first.eve_group_id
        pap.fleet_role = r.fleet_role if r.ship_type_id == pap.ship_type_id
      }

      pap.save
    end
end
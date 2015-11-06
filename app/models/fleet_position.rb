class FleetPosition < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :fleet_id,           type: :integer
  property :character_id,       type: :integer, limit: 8 , default: "0"
  property :char_name,          type: :string, limit: 255, default: ""
  property :main_name,          type: :string, limit: 255, default: ""
  property :corp_name,          type: :string, limit: 255, default: ""
  property :corporation_id,     type: :integer, limit: 8 , default: "0"
  property :alliance_name,      type: :string, limit: 255, default: ""
  property :alliance_id,        type: :integer, limit: 8 , default: "0"
  property :station_id,         type: :integer, limit: 8 , default: "0"
  property :station_name,       type: :string, limit: 255, default: ""
  property :solar_system_id,    type: :integer, limit: 8 , default: "0"
  property :solar_system_name,  type: :string, limit: 255, default: ""
  property :constellation_id,   type: :integer, limit: 8 , default: "0"
  property :constellation_name, type: :string, limit: 255, default: ""
  property :region_id,          type: :integer, limit: 8 , default: "0"
  property :region_name,        type: :string, limit: 255, default: ""
  property :ship_id,            type: :integer, limit: 8 , default: "0"
  property :ship_name,          type: :string, limit: 255, default: ""
  property :ship_type_id,       type: :integer, limit: 8 , default: "0"
  property :ship_type_name,     type: :string, limit: 255, default: ""
  property :ship_group_id,       type: :integer, limit: 8 , default: "0"
  property :ship_group_name,     type: :string, limit: 255, default: ""
  property :rules_applied,      type: :boolean, default: "0"
  property :fleet_role,         type: :string, limit: 255, default: "Other" #as: "ENUM('Other','Fleet','Logistics','Command_Ship','Black_Ops','Capital','Super.Titan')"
  property :special_role,       type: :string, limit: 255, default: "none"  #as: "ENUM('none','FC','Co-FC','Logi_FC','Scout','Prober','Target_Caller')"
  timestamps

  belongs_to :fleet
  belongs_to :character

  add_index [:fleet_id,:character_id], name: 'fleet_character'

  def docked
    return "docked" if !station_name.nil?
  end

  def docked?
    true if !station_name.nil?
    false
  end

  def set_from_env(env)
    # set everything just in case member has changed corp, etc.
    self.character_id = env["HTTP_EVE_CHARID"]
    self.char_name = env["HTTP_EVE_CHARNAME"]
    self.corp_name = env["HTTP_EVE_CORPNAME"]
    self.corporation_id = env["HTTP_EVE_CORPID"]
    self.alliance_name = env["HTTP_EVE_ALLIANCENAME"]
    self.alliance_id = env["HTTP_EVE_ALLIANCEID"]
    self.region_name = env["HTTP_EVE_REGIONNAME"]
    self.constellation_name = env["HTTP_EVE_CONSTELLATIONNAME"]
    self.solar_system_name = env["HTTP_EVE_SOLARSYSTEMNAME"]
    self.station_name = env["HTTP_EVE_STATIONNAME"]
    self.ship_name = env["HTTP_EVE_SHIPNAME"]
    self.ship_id = env["HTTP_EVE_SHIPID"]
    self.ship_type_name = env["HTTP_EVE_SHIPTYPENAME"]
    self.ship_type_id = env["HTTP_EVE_SHIPTYPEID"]
  end
end
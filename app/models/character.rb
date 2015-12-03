# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  char_name          :string(255)
#  corp_name          :string(255)
#  alliance_name      :string(255)
#  station_name       :string(255)
#  solar_system_name  :string(255)
#  constellation_name :string(255)
#  region_name        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  fleet_id           :integer
#  changed_at         :datetime
#  tag_id             :integer
#


class Character < ActiveRecord::Base
  STALE = 2
  ABANDONED = 10
  PURGE = 20

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  attr_accessor :ship_id, :ship_name, :ship_type_id, :ship_type_name, :fleet_id, :fleet, :env

  property :char_id,            type: :integer, limit: 8 , default: "0"
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
  property :user_id,            type: :integer, default: "0"
  property :main_char_id,            type: :integer, default: "0"
  timestamps
  #property :tag_id,             :integer

  add_index [:char_name], name: 'by_char_name'

  
  #validates_presence_of :char_name, :corp_name
  #validates_uniqueness_of :char_name
  
  before_save :check_for_changes
  
  belongs_to :fleet, :counter_cache => true
  belongs_to :tag
  belongs_to :user
  belongs_to :eve_api_key

  belongs_to :main, class_name: "Character", foreign_key: "main_char_id"

  #default_scope { :order => 'char_name' }
  
  # scope :abandoned, lambda {
  #   where("fleet_id IS NOT NULL and updated_at < ?", ABANDONED.minutes.ago)
  # }

  # scope :stale, lambda {
  #   where("fleet_id IS NOT NULL and updated_at < ?", STALE.minutes.ago)
  # }

  # scope :to_be_purged, lambda {
  #   where("fleet_id IS NOT NULL and updated_at < ?", PURGE.minutes.ago)
  # }
  
  # scope :tagged, where("tag_id IS NOT NULL")

  def get_main
    return nil if main_char_id <= 0
    Character.find(main_char_id)
  end

  def tag=(tag)
    # TODO Should check if tag is actually changed
    # increments even if user is not saved
    if tag
      self.tag_id = tag.id
      tag.increment!(:usage_count)
    else
      self.tag_id = nil
    end
    return tag
  end
  
  def in_fleet?(fleet)
    fleet_id == fleet.id
  end
  
  def join_fleet(fleet)
    self.fleet = fleet
    self.fleet_id = fleet.id
    self.tag = nil # Shouldn't be necessary
    save
  end
  
  def leave_fleet
    self.fleet = nil
    self.tag = nil
    save
  end

  def self.create_from_razor_smf(id, char_name, main_char_id, main_char_name)
    c = Character.where(:id => id).first
    c = Character.new(:char_name => char_name) if c.nil?
    m = Character.where(:id => main_char_id).first
    m = Character.new(:char_name => char_name) if m.nil?
    c.char_name = char_name if c.char_name.nil?
    m.id = main_char_id
    m.char_name = main_char_name if m.char_name.nil?
    m.save
    c.id = id
    c.main_char_id = main_char_id
    c.main_name = m.char_name
    c.save

  end

  def set_from_env(env)
    self.env ||= env
    # set everything just in case member has changed corp, etc.
    self.char_id = env["HTTP_EVE_CHARID"]
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
  
  def self.find_or_initialize_from_env(env)
    if !env["HTTP_EVE_CHARID"].blank?
      char = Character.find_or_create_by(id: env["HTTP_EVE_CHARID"])
    end
  end
  
  def self.new_or_update_from_env(env)
    if !env["HTTP_EVE_CHARID"].blank?
      char = Character.find_or_create_by(id: env["HTTP_EVE_CHARID"])
      char.set_from_env(env)
    end
    return char
  end
  
  def self.new_or_update_from_env_and_save(env)
    if !env["HTTP_EVE_CHARID"].blank?
      char = Character.find_or_create_by(id: env["HTTP_EVE_CHARID"])
      char.set_from_env(env)
      char.updated_at = Time.now # To force an update
      char.save
      #Logger.new(STDOUT).info('updated user')
    end
    return char
  end

  def self.find_or_initialize_by_char_name(char_name)
    char = Character.where(:char_name => char_name).first
    char = Character.create(:char_name => char_name) if char.nil?

    return char
  end
  
  def stale?
    updated_at < STALE.minute.ago
  end
  
  def abandoned?
    updated_at < ABANDONED.minutes.ago
  end
  
  def check_for_changes
    #self.changed_at = Time.now if self.solar_system_name_changed? || self.tag_id_changed? || self.fleet_id_changed?
  end
  
  def global_admin?
    return true if (GlobalAdmin.find_by_char_name(self.char_name))
  end
  
  def self.purge
    chars = Character.to_be_purged
    chars.map(&:leave_fleet)
    return chars
  end
  
end

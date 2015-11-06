class Fleet < ActiveRecord::Base
  property :token,                       type: :string, limit: 50
  property :fc_name,                     type: :string, limit: 255
  property :fleet_name,                  type: :string, limit: 255
  property :fleet_time,                  type: :string, limit: 50
  property :fleet_at,                    type: :datetime
  property :fleet_coms,                  type: :string, limit: 50
  property :description,                 type: :text
  property :close_at,                    type: :datetime
  property :status,                      type: :integer, default: "0"
  timestamps

  before_create :initialize_fleet

  def to_s
    # We use this to match our exported information, otherwise we don't really care
    "#{fleet_name}, #{fc_name}, #{fleet_time}, #{fleet_coms}"
  end

  def status_to_s
    "open" if status == 0
    "close" if status == 1
    "ignored" if status == 2
  end

  def open?
    return true if status == 0
    false
  end

  def closed?
    return true if status == 1
    false
  end

  def initialize_fleet
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.close_at = DateTime.now + 1.hour
  end

  def join(character)
    pap = FleetPosition.create(:fleet => self, :character => character) if FleetPosition.where(:fleet_id => self.id,:character_id => character.id).count < 1
    if pap.nil?
      pap = FleetPosition.where(:fleet_id => self.id,:character_id => character.id).first
    end
    pap.set_from_env(character.env)
    pap.save
    # Resque.enqueue SingleFleetPositionRulesJob pap.id
    FleetPositionRules.apply_rules(pap.id)
  end

  def join_with_special_role(character, special_role)
    pap = FleetPosition.create(:fleet => self, :character => character) if FleetPosition.where(:fleet_id => self.id,:character_id => character.id).count < 1
    if pap.nil?
      pap = FleetPosition.where(:fleet_id => self.id,:character_id => character.id).first
    end
    pap.special_role = special_role
    pap.char_name = character.char_name
    pap.main_name = character.main.char_name if character.main
    pap.save
  end
end
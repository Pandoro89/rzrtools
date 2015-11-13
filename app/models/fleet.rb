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
  property :created_by_id,               type: :integer
  timestamps

  has_many :fleet_positions
  belongs_to :created_by, :class_name => "User"

  before_create :initialize_fleet

  # validates :fleet_name, :presence => true, :if => :condition_testing?

  scope :open, -> { where(status: 0) }
  scope :closed, -> { where(status: 1) }
  scope :ignored, -> { where(status: 2) }

  def initialize_fleet
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.close_at = DateTime.now + 1.hour
    self.fleet_at = DateTime.now
  end

  def validate_open_fleet_name
   errors.add(:base, "There is already an open fleet with that name.") if Fleet.where(:name => name, :status => 0).size > 0
  end

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

  def has_capitals?
    return true if fleet_positions.where(:fleet_role => [])
    false
  end

  def recent_fleets
    
  end

  def join(character)
    pap = FleetPosition.create(:fleet => self, :character => character) if FleetPosition.where(:fleet_id => self.id,:character_id => character.id).count < 1
    if pap.nil?
      pap = FleetPosition.where(:fleet_id => self.id,:character_id => character.id).first
    end
    pap.set_from_env(character.env)
    pap.save
    # Resque.enqueue SingleFleetPositionRulesJob pap.id
    FleetPositionRule.apply_rules(pap.id)
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

  def remove_with_special_role(character, special_role)
    return if FleetPosition.where(:fleet_id => self.id,:character_id => character.id).count < 1
    pap = FleetPosition.where(:fleet_id => self.id,:character_id => character.id).first
    pap.special_role = 'none'
    if pap.ship_type_id.nil? or pap.ship_type_id <= 0
      pap.delete 
      return
    end
    pap.save
  end

  def self.pilot_rewards_other(m, y)
    first_date = DateTime.parse("#{y}-#{m}-1 00:00:00")
    fleet_ids= Fleet.where("fleet_at >= ? and fleet_at < ?", first_date, first_date.at_beginning_of_month.next_month).collect {|f| f.id }
    paps=FleetPosition.where("fleet_id IN (?) AND fleet_role != ?", fleet_ids, "Logistics").order(:main_name, :char_name)

    Fleet.pilot_rewards(paps, 3_000_000_000)
  end

  def self.pilot_rewards_logistics(m, y)
    first_date = DateTime.parse("#{y}-#{m}-1 00:00:00")
    fleet_ids= Fleet.where("fleet_at >= ? and fleet_at < ?", first_date, first_date.at_beginning_of_month.next_month).collect {|f| f.id }
    paps = FleetPosition.where("fleet_id IN (?) AND fleet_role = ?", fleet_ids, "Logistics").order(:main_name, :char_name)

    Fleet.pilot_rewards(paps, 3_000_000_000)
  end

  def self.pilot_rewards(paps, pap_amt)
    max_places=20
    retRewards = {}
    paps.each {|p| 
      name = (!p.main_name.nil?) ? p.main_name : p.char_name;
      if retRewards[name].nil?
        retRewards[name] = {:name => name, :corp_name =>  p.corp_name, :fleets => 1, :payout => nil, :place => -1}
      else
        retRewards[name][:fleets] += 1
      end
    }

    retRewards = Hash[retRewards.sort_by{ |_, v| -v[:fleets] }]# .sort_by{|_key, value| value[:fleets]}.reverse!

    p = 1
    sumPap = 0
    place = 1
    realPlace = place
    lastFleets = 0 
    retRewards.each { |k,r| 
      if(retRewards[k][:fleets] != lastFleets)
        place = realPlace
      end

      retRewards[k][:place] = place

      if place <= max_places
        sumPap += retRewards[k][:fleets]
      end

      realPlace += 1
      lastFleets = retRewards[k][:fleets]
    }

    #puts retRewards.to_json

    if sumPap > 0
      perPap = pap_amt / sumPap;
    else
      perPap = 0
    end
    retRewards = retRewards.collect { |k,r|    
      if(r[:place] <= max_places)
        [:name => r[:name], :corp_name => r[:corp_name], :fleets => r[:fleets], :place => r[:place], :payout =>  perPap * r[:fleets]] 
      elsif r[:name] != ""
        [:name => r[:name], :corp_name => r[:corp_name], :fleets => r[:fleets], :place => r[:place], :payout =>  0] 
      end
    }.reject{|r| r.nil? }.flatten

    return retRewards
  end
end 
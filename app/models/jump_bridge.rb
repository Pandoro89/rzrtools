class JumpBridge < ActiveRecord::Base
  property :from_solar_system_id,         type: :integer, default: "0" 
  property :to_solar_system_id,           type: :integer, default: "0"  
  property :from_planet,                  type: :integer 
  property :from_moon,                    type: :integer 
  property :to_planet,                    type: :integer 
  property :to_moon,                      type: :integer 
  property :status,                       type: :integer,  default: "1"
  property :deleted_at,                   type: :datetime
  timestamps
  acts_as_paranoid

  def online?
    return true if status == 1
    false
  end

  def status_to_s
    return "online" if status == 1
    return "offline (temporary)" if status == 2
    "offline"
  end
end
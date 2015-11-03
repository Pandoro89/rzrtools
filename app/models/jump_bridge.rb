class JumpBridge < ActiveRecord::Base
  property :from_solar_system_id,            type: :integer 
  property :to_solar_system_id,            type: :integer 
  property :from_planet,            type: :integer 
  property :from_moon,            type: :integer 
  property :to_planet,            type: :integer 
  property :to_moon,            type: :integer 
  property :status,           type: :boolean,  default: "1"
  timestamps

  def online?
    return true if status == 1
    false
  end
end
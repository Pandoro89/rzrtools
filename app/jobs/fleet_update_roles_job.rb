class FleetUpdateRolesJob < Resque::Job
  @queue = :high

  def self.perform(fleet_id)
    FleetPosition.where(:fleet_id => fleet_id,:rules_applied => 0).each { |fp|
      FleetPositionRule.apply_rules(fp.id)
    }
  end

end
class SingleFleetPositionRulesJob < Resque::Job
  @queue = :medium

  def self.perform(id)
    FleetPositionRules.apply_rules(id)
  end
end
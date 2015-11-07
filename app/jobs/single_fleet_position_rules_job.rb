class SingleFleetPositionRulesJob < Resque::Job
  @queue = :medium

  def self.perform(id)
    FleetPositionRule.apply_rules(id)
  end
end
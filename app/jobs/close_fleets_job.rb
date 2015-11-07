class ImportCharacterByNameJob < Resque::Job
  @queue = :high

  def selfperform()
    Fleet.where("status=0 AND close_at <= ?",DateTime.now).each{ |f|
      # Close when we have people
      f.update_attributes(:status => 1) if f.fleet_positions.size > 5
      # Ignore it if no one joined
      f.update_attributes(:status => 2) if f.fleet_positions.size == 0
      # Discard if?
      f.update_attributes(:status => 2) if f.fleet_positions.size < 5 and !fleet.has_capitals?

      # Resque.enqueue FleetUpdateRole
    }
  end
end
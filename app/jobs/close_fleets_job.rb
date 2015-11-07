class CloseFleetsJob < Resque::Job
  @queue = :high

  def self.perform()
    Fleet.where("status=0 AND close_at <= ?",DateTime.now).each{ |f|
      if f.fleet_positions.size < 5 and !f.has_capitals?
        f.update_attributes(:status => 2) 
      elsif f.fleet_positions.size == 0
        f.update_attributes(:status => 2)
      else
        f.update_attributes(:status => 1)
      end

      f.save

      Resque.enqueue FleetUpdateRolesJob, f.id
    }
  end
end
class FleetsUpdateRolesJob < Resque::Job
  @queue = :medium

  def self.perform()
    Fleet.where("created_at >= ?", DateTime.now - 1.month).each {|f|
      Resque.enqueue FleetUpdateRolesJob, f.id
    }
  end

end
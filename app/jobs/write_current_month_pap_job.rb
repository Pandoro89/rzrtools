class WriteCurrentMonthPapJob < Resque::Job
  @queue = :medium

  def self.perform()
    
  end
end
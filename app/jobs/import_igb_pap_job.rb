class ImportIgbPapJob < Resque::Job
  @queue = :low 

  def self.perform()
    Resque.enqueue ImportIgbPapsJob, "members_current.csv"
  end
end
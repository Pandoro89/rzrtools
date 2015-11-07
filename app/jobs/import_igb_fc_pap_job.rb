class ImportIgbFcPapJob < Resque::Job
  @queue = :low 

  def self.perform()
    Resque.enqueue ImportIgbFcPapsJob, "members_fc_current.csv"
  end
end
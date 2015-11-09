class ImportAltSpreadsheetJob < Resque::Job
  @queue = :low 

  def self.perform()
  end
end
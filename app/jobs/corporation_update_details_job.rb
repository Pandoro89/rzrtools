class CorporationUpdateDetailsJob < Resque::Job
  @queue = :medium

  def self.perform(id)
    Eve::CorporationCache.update_from_api(id)
  end
end
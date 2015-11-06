class UpdateApiKeyJob < Resque::Job
  @queue = :high

  def self.perform(id)
    Eve::ApiKey.find(id).update_characters
    Eve::ApiKey.find(id).update_access_mask
  end
end
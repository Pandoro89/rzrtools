class UpdateApiKeyJob < Resque::Job
  @queue = :high

  def self.perform(id)
    Eve::ApiKey.find(id).update_characters
  end
end
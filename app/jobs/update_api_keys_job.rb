class UpdateApiKeysJob < Resque::Job
  @queue = :high

  def self.perform()
    Eve::ApiKey.update_all_characters
    User.remove_roles_for_non_alliance
    nil
  end
end
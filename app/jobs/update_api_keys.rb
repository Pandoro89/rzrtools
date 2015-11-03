class UpdateApiKeysJob < Resque::Job
  @queue = :high
end
class ImportZkillboardWatchlistJob < Resque::Job
  @queue = :low


  def self.perform()
    # Supers: SELECT * FROM inv_types WHERE eve_group_id = 659
    # Titans: SELECT * FROM inv_types WHERE eve_group_id = 30
    # https://zkillboard.com/api/kills/shipID/644,638/orderDirection/asc/
    Watchlist.import_zkillboard
  end


end
class LetsencryptPluginChallenge < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :response,                       type: :text
  timestamps


end
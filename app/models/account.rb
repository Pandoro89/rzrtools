class Account < ActiveRecord::Base
  
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  
  timestamps
end
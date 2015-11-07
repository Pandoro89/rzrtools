class Eve::Group < ActiveRecord::Base
  include IdentityCache

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :eve_category_id,            type: :integer , limit: 8
  property :name,                       type: :string



end
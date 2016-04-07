class RashHistory < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :user_id,           type: :integer, default: "0"
  property :rash_member_id,    type: :integer, default: "0"
  property :message,           type: :text
  property :message_markdown,  type: :text
  property :duplicate,         type: :boolean, default: "0"
  property :jabber,            type: :string, limit: 50
  property :bot,               type: :string, limit: 250
  timestamps

end
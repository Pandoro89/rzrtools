class RashMember < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :user_id,            type: :integer, default: "0"
  property :rash,               type: :string, limit: 50
  property :jabber,             type: :string, limit: 50
  property :irc,                type: :boolean, default: "0"
  property :irc_filter,         type: :text
  property :jabber_filter,         type: :text
  property :relay_for,          type: :text
  timestamps

end
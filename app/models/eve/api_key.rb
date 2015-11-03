class Eve::ApiKey < ActiveRecord::Base

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :key_code,            type: :string, limit: 50
  property :vcode,            type: :string, limit: 255
  property :access_mask,            type: :string, limit: 50 
  property :expires_at,            type: :datetime

  timestamps

  belongs_to :user

  validates :key_code, presence: true, :on=>:create
  validates :vcode, presence: true, :on=>:create
  
  def update_characters
    api = EAAL::API.new(key_code, vcode)
    result = api.Characters
    result.characters.each{|character|
        char = Character.find_or_initialize_by_char_name(character.name)
        char.id = character.characterID
        char.user_id = user_id
        char.alliance_id = character.allianceID
        char.alliance_name = character.allianceName
        char.corporation_id = character.corporationID
        char.corp_name = character.corporationName
        char.save
    }


    result
  end

end
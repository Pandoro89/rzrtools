class Eve::ApiKey < ActiveRecord::Base

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :key_code,            type: :string, limit: 50
  property :vcode,            type: :string, limit: 255
  property :access_mask,            type: :string, limit: 50 
  property :expires_at,            type: :datetime
  timestamps

  belongs_to :user

  validates :key_code, presence: true
  validates :vcode, presence: true

  after_create :queue_update

  def queue_update
    Resque.enqueue UpdateApiKeyJob, id
  end

  def update_access_mask
    api = EAAL::API.new(key_code, vcode)
    result = api.APIKeyInfo
    self.access_mask = result.key.attribs["accessMask"]
    self.expires_at = result.key.attribs["expires"]
    self.save
    return
  end
  
  def update_characters
    first_razor_char_id = 0
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
        first_razor_char_id = character.characterID if ALLIANCE_ID==character.allianceID
    }

    if user.main_char_id == 0
      user.updatE_attributes(:main_char_id => first_razor_char_id)
    end
  end

  def self.update_all_characters
    Eve::ApiKey.all.each{ |a| a.update_characters}
  end

end
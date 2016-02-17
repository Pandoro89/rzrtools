class Eve::ApiKey < ActiveRecord::Base

  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"

  property :key_code,            type: :string, limit: 50
  property :vcode,            type: :string, limit: 255
  property :access_mask,            type: :string, limit: 50 
  property :expires_at,            type: :datetime
  timestamps

  belongs_to :user
  has_many :characters, :foreign_key => :eve_api_key_id

  validates :key_code, presence: true
  validates :vcode, presence: true

  after_create :queue_update
  before_destroy { |record| Character.where(:eve_api_key_id => record.id).update_attributes(:user_id => 0, :eve_api_key_id => 0) }

  def queue_update
    Resque.enqueue UpdateApiKeyJob, id if !user.nil?
  end

  def update_access_mask
    api = EAAL::API.new(key_code, vcode)
    result = api.APIKeyInfo
    self.access_mask = result.key.attribs["accessMask"]
    # self.expires_at = DateTime.parse(result.key.attribs["expires"])
    self.save
    return
  end
  
  def update_characters
    first_razor_char_id = 0
    first_blue_char_id = 0
    begin
      api = EAAL::API.new(key_code, vcode)
      result = api.Characters
    rescue 
      return 
    end
    result.characters.each{ |character|
        char = Character.where(:id => character.characterID).first
        char ||= Character.new(:id => character.characterID, :char_name => character.name)
        char.id = character.characterID
        char.user_id = user_id
        char.alliance_id = character.allianceID
        char.alliance_name = character.allianceName
        char.corporation_id = character.corporationID
        char.corp_name = character.corporationName
        char.eve_api_key_id = id
        char.save
        first_razor_char_id = char.id if ALLIANCE_ID.to_i == character.allianceID.to_i and first_razor_char_id == 0
        first_blue_char_id = char.id if BLUE_LIST.include?(character.allianceID.to_i) and first_blue_char_id == 0
    }

    # TODO: We should really diff the char_id's so we can know when a character "disappears" from the api, and do something with it

    if (user.main_char_id.nil? or user.main_char_id == 0) and first_razor_char_id > 0
      user.update_attributes(:main_char_id => first_razor_char_id)
      user.add_role ROLE_RAZOR_MEMBER
    elsif (user.main_char_id.nil? or user.main_char_id == 0) and first_blue_char_id > 0
      user.update_attributes(:main_char_id => first_blue_char_id)
      user.add_role ROLE_RAZOR_MEMBER
    end
  end

  def self.update_all_characters
    Eve::ApiKey.all.each{ |a| a.update_characters }
  end

end
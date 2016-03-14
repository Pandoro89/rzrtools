class User < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  rolify
  property :username,                       type: :string, limit: 50
  property :password_digest,                type: :string, limit: 255
  property :password_recovery_code,         type: :string, limit: 50
  property :password_recovery_code_sent_at, type: :datetime
  property :email,                          type: :string, limit: 50
  property :generation,                     type: :integer, default: "1"
  property :last_login_at,                  type: :datetime
  property :main_char_id,                   type: :integer
  property :deleted_at,                     type: :datetime
  timestamps

  has_many :api_keys, class_name: "Eve::ApiKey"
  has_many :roles, :through => :users_roles, dependent: :destroy
  belongs_to :main_char, class_name: "Character"
  has_many :characters, class_name: "Character"
  # belongs_to :users_roles

  has_secure_password
  validates :username, uniqueness: true, length: { minimum: 3 }
  EMAIL_REGEX = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  validates :email, uniqueness: true, length: { minimum: 3 }, :format => EMAIL_REGEX
  validates :password, presence: true, length: { minimum: 6 }, :on=>:create
  validates :password_confirmation, :presence=>true, :if => :password_digest_changed?

  accepts_nested_attributes_for :api_keys, allow_destroy: true

  after_save :queue_update

  def delete_role(role_name)
    @r = Role.where(:name => role_name).first
    return if !@r

    roles.delete(@r)
  end


  def queue_update
    api_keys.each {|a| 
      Resque.enqueue UpdateApiKeyJob, a.id
    }
  end

  def before_add_method(role)
    # do something before it gets added
    add_role "Razor Member" if role == "Scout Commander"
    add_role "Razor Member" if role == "Fleet Commander"
    add_role "Razor Member" if role == "Admin"
    add_role "Razor Member" if role == "Troika"
    add_role "Blue Member"  if main_char and main_char.is_blue?
  end

  def admin?
    has_role? "Admin"
  end

  def troika?
    has_role? "Troika"
  end

  def scout_commander?
    has_role? "Scout Commander"
  end

  def military_advisor?
    has_role? "Military Advisor"
  end  

  def fleet_commander?
    has_role? ROLE_FLEET_COMMANDER
  end  

  def razor_member?
    has_role? "Razor Member"
  end

  def blue_member?
    has_role? "Blue Member"
  end

  def can_make_paps?
    has_role? ROLE_MAKE_PAPS or has_role? ROLE_FLEET_COMMANDER or has_role? ROLE_MILITARY_ADVISOR
  end  


  def self.login(username, password)
    return nil if username.blank?

    user = User.where(:username => username).first
    if user and user.authenticate(password)
      user.generation = user.generation + 1
      user.last_login_at = DateTime.now
      user.save!
      return user 
    end

    nil
  end

  def self.find_by_id_generation(id, generation)
    where(:id => id, :generation => generation).first
  end

  def self.remove_roles_for_non_alliance
    
    User.all.each do |u|
      readd_blue = (Character.where(:user_id => u.id, :alliance_id => BLUE_LIST).count > 0)
      u.roles.each {|r| u.roles.delete(r) if !(r==ROLE_BLUE_MEMBER and readd_blue) } if Character.where(:user_id => u.id, :alliance_id => ALLIANCE_ID).count == 0
      u.add_role ROLE_BLUE_MEMBER if readd_blue
    end

  end

end
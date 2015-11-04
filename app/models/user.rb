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
  property :main_char_id,                     type: :integer
  timestamps

  has_many :api_keys, class_name: "Eve::ApiKey"
  has_many :roles, :through => :users_roles
  belongs_to :main_char, class_name: "Character"

  has_secure_password
  validates :username, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, :on=>:create
  validates :password_confirmation, :presence=>true, :if => :password_digest_changed?

   accepts_nested_attributes_for :api_keys, allow_destroy: true


  def before_add_method(role)
    # do something before it gets added
    add_role "Razor Member" if role == "Fleet Commander"
  end

  def admin?
    has_role? "Admin"
  end

  def scout_commander?
    has_role? "Scout Commander"
  end

  def military_advisor?
    has_role? "Military Advisor"
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
      u.roles.each {|r| user.remove_role r} if Character.where(:user_id => u.id, :alliance_id => ALLIANCE_ID).count == 0
    end
  end

end
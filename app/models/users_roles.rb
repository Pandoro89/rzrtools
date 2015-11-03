class UsersRoles < ActiveRecord::Base
    property :user_id,           type: :integer
    property :role_id,       type: :integer
end
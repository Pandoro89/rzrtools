# class Api::V1::CharacterSerializer < Api::V1::BaseSerializer
#   attributes :id, :char_name, :main_name,  :corp_id, :corp_name, :alliance_name, :alliance_id, :admin, :created_at, :updated_at


#   def created_at
#     object.created_at.in_time_zone.iso8601 if object.created_at
#   end

#   def updated_at
#     object.updated_at.in_time_zone.iso8601 if object.created_at
#   end
# end
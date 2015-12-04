class Admin::OperationsController < Admin::ApplicationController
  before_filter :require_global_admin

  def manual_alts
    api = EAAL::API.new("", "")
    api.scope = "eve"

    if request.post?
      split = params[:pasted].lines
      split.each {|s|
        split_tabs = s.split("\t")
        main = split_tabs.first
        main_c = nil
        split_tabs.each {|t|
          t=t.strip
          next if t.nil? or t == ""
          c = Character.where(:char_name => t).first
          if c.nil?
            result = api.CharacterID(:names => t)
            c = Character.new(:char_name => t, :id => result.characters.first.characterID) 
          end
          if main_c.nil?
            main_c = c
          else
            c.main_name = main_c.char_name
            c.main_char_id = main_c.id
          end
          c.save
        }
      }
    end

  end
end
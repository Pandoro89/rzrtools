class Admin::OperationsController < Admin::ApplicationController
  before_filter :require_global_admin

  def manual_jump_bridges
    if request.post?
      split = params[:pasted].lines
      split.each {|s|
        next if s =~ /The Webway/ or s =~ /Region/
        split_tabs = s.split("\t")
        jb = nil
        split_tabs
        t = split_tabs
          next if t.nil? or t == ""

          left = t[1].strip.split("@")
          right = t[2].strip.split("@")
          to_system = left[0].strip
          puts "#{left} , #{right}"
          to_system_id = Eve::SolarSystem.where(:name => to_system.strip).first.try(:id)
          to_planet = left[1].strip.split("-")[0].strip
          to_moon = left[1].strip.split("-")[1].strip
          from_system = right[0].strip
          from_system_id = Eve::SolarSystem.where(:name => from_system.strip).first.try(:id)
          from_planet = right[1].strip.split("-")[0].strip
          from_moon = right[1].strip.split("-")[1].strip

          puts "from #{from_planet}-#{from_moon}"

          jb = JumpBridge.where(:from_solar_system_id => from_system_id, :to_solar_system_id => to_system_id).first if jb.nil?
          jb = JumpBridge.where(:from_solar_system_id => to_system_id, :to_solar_system_id => from_system_id).first if jb.nil?
          jb = JumpBridge.new(:from_moon=> from_moon, :from_planet=>from_planet, :to_moon=> to_moon, :to_planet=>to_planet, :from_solar_system_id => from_system_id, :to_solar_system_id => to_system_id) if jb.nil?

          jb.from_moon = from_moon
          jb.from_planet = from_planet
          jb.to_moon = to_moon
          jb.to_planet = to_planet

          jb.save


        
      }
    end
  end

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
            c = Character.where(:id => result.characters.first.characterID).first
            c = Character.new(:char_name => t, :id => result.characters.first.characterID) if c.nil?
            c.char_name = t
          end
          if main_c.nil?
            main_c = c
          elsif c.char_name != main_c.char_name
            c.main_name = main_c.char_name
            c.main_char_id = main_c.id
          end
          c.save
        }
      }
    end

  end
end
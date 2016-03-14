#require 'http_logger'

class ImportLocatorAgentNotificationsJob < Resque::Job
  @queue = :high

  def self.perform(api_key_ids = [],char_ids = [])
    query = Eve::ApiKey.all
    query = Eve::ApiKey.where(:id => api_key_ids) if api_key_ids and api_key_ids.size > 0
    query = Eve::ApiKey.where(:characters => {:id => char_ids}) if char_ids and char_ids.size > 0
    query.each do |ak|
      ak.characters.each do |char|
        result = nil
        begin
          api = EAAL::API.new(ak.key_code, ak.vcode)
          api.scope = "char"
          result = api.Notifications(:characterID => char.id)
        rescue => ee
          pp "error1"
          next 
        end

        next if result.nil?

        notification_ids = []
        notification_dates = {}
        result.notifications.each do |r|
          next unless r.typeID == AGENT_LOCATES_CHARACTER
          if r.notificationID.to_i > char.last_notification_id
            notification_ids.push r.notificationID.to_i 
            notification_dates[r.notificationID.to_s] = DateTime.parse(r.sentDate)
          end
        end

        next if notification_ids.size == 0

        begin
          # view-source:https://api.eveonline.com/char/NotificationTexts.xml.aspx?Ids=553692554&characterID=1746956241&keyid=&vcode=
          #result2 = api.NotificationTexts(:characterID => char.id, :IDs => )
          result2 = HTTParty.get("https://api.eveonline.com/char/NotificationTexts.xml.aspx?Ids=#{notification_ids.sort.join(",")}&characterID=#{char.id}&keyid=#{ak.key_code}&vcode=#{ak.vcode}") 
          data = result2.parsed_response
        rescue => e
          pp e
          next 
        end

        #

# <?xml version='1.0' encoding='UTF-8'?>
# <eveapi version="2">
#   <currentTime>2016-03-13 16:54:20</currentTime>
#   <result>
#     <rowset name="notifications" key="notificationID" columns="notificationID">
#       <row notificationID="553692554"><![CDATA[agentLocation:
#   3: 10000033
#   4: 20000410
#   5: 30002798
#   15: 60003853
# characterID: 371861578
# messageIndex: 0
# targetLocation:
#   3: 10000015
#   4: 20000193
#   5: 30001324
# ]]></row>
#     </rowset>
#   </result>
#   <cachedUntil>2026-03-11 16:54:20</cachedUntil>
# </eveapi>

        result2["eveapi"]["result"]["rowset"]["row"].each do |r|
          if r["__content__"]
            match = /characterID: ([\d]*)$/.match(r["__content__"])
            c_id = match[1] if match
            
            targetString = r["__content__"].partition('targetLocation:').last
            match = /5: ([\d]*)$/.match(targetString)
            s_id = match[1]
            match = /15: ([\d]*)$/.match(targetString)
            st_id = match[1] if !match.nil? and match.size > 0

            w = Watchlist.where(:char_id => c_id).first
            if w 
              w.solar_system_id = s_id
              w.solar_system_name = Eve::SolarSystem.find(s_id).name
              w.last_seen_at = notification_dates[r["notificationID"].to_s]
              w.locator_seen_at = notification_dates[r["notificationID"].to_s]
              w.save

              char.last_notification_id = r["notificationID"].to_i if r["notificationID"].to_i > char.last_notification_id
              char.save
            end
          end
        end

      end # end char


    end
  end
end
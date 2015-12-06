class ExportMembersCsvJob
  @queue = :low
  
  def self.perform()
    file_path = Rails.root.join('public','static','pap','a','741557221','members_current.csv')

    CSV.open(file_path, "w", {:force_quotes => true}) do |csv|
      csv << ['Pilot','Main','Corp','Fleet Ship','Ship Group','Date','Time Created']
      FleetPosition.where("created_at >= ? AND created_at < ? AND fleet_id NOT IN (SELECT id FROM fleets WHERE status > 1)",Date.today.beginning_of_month,Date.today.beginning_of_month+1.month).each {|fp|
        csv << [fp.char_name, fp.main_name, fp.corp_name, fp.ship_type_name, fp.ship_group_name, fp.created_at.strftime('%m/%d/%Y'),  fp.created_at.strftime('%H:%M:%S')]
      }
    end
  end
end
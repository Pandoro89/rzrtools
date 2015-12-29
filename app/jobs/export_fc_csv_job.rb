class ExportFcCsvJob
  @queue = :low
  
  def self.perform()
    month_dt = Date.today.beginning_of_month
    file_path = Rails.root.join('public','static','pap','a','741557221','members_fc_'+month_dt.strftime('%Y%m')+'.csv')

    CSV.open(file_path, "w", {:force_quotes => true}) do |csv|
      csv << ['Pilot','Main','Corp', 'Fleet','Fleet Size','Role','Ship','Ship Group','Date','Time Created']
      FleetPosition.where("special_role != 'none' AND special_role IS NOT NULL AND created_at >= ? AND created_at < ? AND fleet_id NOT IN (SELECT id FROM fleets WHERE status > 1) AND alliance_id = ?",month_dt, month_dt +1.month, ALLIANCE_ID).each {|fp|
        csv << [fp.char_name, fp.main_name, fp.corp_name, fp.fleet.to_s, Fleet.find(fp.fleet_id).fleet_positions.count, fp.special_role,fp.ship_type_name, fp.ship_group_name, fp.created_at.strftime('%m/%d/%Y'),  fp.created_at.strftime('%H:%M:%S')]
      }
    end
  end
end
class ExportLastMonthsCsvJob
  @queue = :low
  
  def self.perform()
    @month ||= (DateTime.now - 1.month).strftime("%m") 
    @year ||= (DateTime.now - 1.month).strftime("%Y")
    file_path = Rails.root.join('public','static','pap','a','741557221',"members_#{@year}#{@month}.csv")
    last_month_date = Date.today.beginning_of_month - 1.month

    CSV.open(file_path, "w", {:force_quotes => true}) do |csv|
      csv << ['Pilot','Main','Corp', 'Fleet','Fleet Ship','Ship Group','Date','Time Created']
      FleetPosition.where("created_at >= ? AND created_at < ? AND fleet_id NOT IN (SELECT id FROM fleets WHERE status > 1)",last_month_date,Date.today.beginning_of_month).each {|fp|
        csv << [fp.char_name, fp.main_name, fp.corp_name, fp.fleet.to_s, fp.ship_type_name, fp.ship_group_name, fp.created_at.strftime('%m/%d/%Y'),  fp.created_at.strftime('%H:%M:%S')]
      }
    end

    file_path = Rails.root.join('public','static','pap','a','741557221','members_fc_'+last_month_date.strftime('%Y%m')+'.csv')

    CSV.open(file_path, "w", {:force_quotes => true}) do |csv|
      csv << ['Pilot','Main','Corp', 'Fleet','Fleet Size','Role','Ship','Ship Group','Date','Time Created']
      FleetPosition.where("special_role != 'none' AND special_role IS NOT NULL AND created_at >= ? AND created_at < ? AND fleet_id NOT IN (SELECT id FROM fleets WHERE status > 1)",last_month_date,Date.today.beginning_of_month).each {|fp|
        csv << [fp.char_name, fp.main_name, fp.corp_name, fp.fleet.to_s, Fleet.find(fp.fleet_id).fleet_positions.count, fp.special_role,fp.ship_type_name, fp.ship_group_name, fp.created_at.strftime('%m/%d/%Y'),  fp.created_at.strftime('%H:%M:%S')]
      }
    end
  end
end
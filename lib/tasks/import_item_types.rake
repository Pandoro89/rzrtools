require 'iconv'

namespace :import do
  task :types => :environment do
    path = Rails.root.join('tmp/inv_types.csv') # or, whatever
    CSV.foreach(path) do |row|
      if !row[0].nil? and row[10].to_i == 1
        item = Eve::InvType.find_or_create_by(id: row[0])
        item.eve_group_id = row[1]
        item.name = Iconv.conv('iso-8859-15', 'utf-8', row[2].gsub("\xC2\x96",'').gsub("\xC2\x93",'').gsub("\xC2\x94",'').gsub("\xC2\x91",'').gsub("\xC2\x92",'').strip)
        #item.description = row[3]
        #item.mass = row[5] if row[5] and row[5].to_i < 100000000000000000000000000000000000
        item.volume = row[5]
        item.capacity = row[6]
        # portion_size= row[6]
        # RACEID = row[7]
        # BASEPRICE= row[8]
        #item.published = row[10]
        #item.icon_id = row[12]


        item.save
      end
    end
  end

  task :groups => :environment do
    path = Rails.root.join('tmp/inv_groups.csv') # or, whatever
    CSV.foreach(path) do |row|
      if !row[0].nil? and row[8].to_i == 1
        item = Eve::Group.find_or_create_by(id: row[0])
        item.eve_category_id = row[1]
        item.name = Iconv.conv('iso-8859-15', 'utf-8', row[2].gsub("\xC2\x96",'').gsub("\xC2\x93",'').gsub("\xC2\x94",'').gsub("\xC2\x91",'').gsub("\xC2\x92",'').strip)

        item.save
      end
    end
  end

  task :regions => :environment do
    path = Rails.root.join('tmp/regions.csv') # or, whatever
    CSV.foreach(path) do |row|
      if !row[0].nil?
        item = Eve::Region.find_or_create_by(id: row[0])
        item.name = Iconv.conv('iso-8859-15', 'utf-8', row[1].gsub("\xC2\x96",'').gsub("\xC2\x93",'').gsub("\xC2\x94",'').gsub("\xC2\x91",'').gsub("\xC2\x92",'').strip)

        item.save
      end
    end
  end

  task :system_jumps => :environment do 
    path = Rails.root.join('tmp/system_jumps.csv') # or, whatever
    CSV.foreach(path) do |row|
       system = Eve::SolarSystemJump.find_or_create_by(from_solar_system_id: row[2],to_solar_system_id: row[3])
       system.from_region_id = row[0]
       system.from_constellation_id = row[1]
       system.from_solar_system_id = row[2]
       system.to_solar_system_id = row[3]
       system.to_constellation_id = row[4]
       system.to_region_id = row[5]

       system.save
     end
  end

  task :systems => :environment do
    path = Rails.root.join('tmp/systems.csv') # or, whatever
    CSV.foreach(path) do |row|
       system = Eve::SolarSystem.find_or_create_by(id: row[2])
       system.region_id = row[0]
       system.constellation_id = row[1]
       system.name = Iconv.conv('iso-8859-15', 'utf-8', row[3].strip)
       system.x = row[4]
       system.y = row[5]
       system.z = row[6]
       # xmin= row[7]
       # xmax= row[8]
       # ymin= row[9]
       # ymax= row[10]
       # zmin= row[11]
       # zmax= row[12]
       # luminos= row[13]
       # border= row[14]
       # fringe= row[15]
       # corridor= row[16]
       # hub= row[17]
       # international= row[18]
       # regional= row[19]
       # const= row[20]
       system.security = row[21]
       # faction= row[12]
       # radius= row[12]
       # suntype= row[12]
       # security class= row[12]


       system.save
     end
    
  end
end
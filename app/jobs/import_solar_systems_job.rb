class ImportSolarSystemsJob < Resque::Job
  @queue = :low

  def self.perform(file)
     path = Rails.root.join(file) # or, whatever
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

end


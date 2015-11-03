class ImportSolarSystemsJob < Resque::Job
  @queue = :low 

  def self.perform(file)
    path = Rails.root.join(file) # or, whatever
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

end


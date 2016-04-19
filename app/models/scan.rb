class Scan < ActiveRecord::Base
  create_table options: "ENGINE=InnoDB ROW_FORMAT=COMPRESSED DEFAULT CHARSET=utf8mb4"
  property :token,              type: :string, limit: 50
  property :scan_type,          type: :string, limit: 50, default: "System"
  property :character_id,       type: :integer, limit: 8 , default: "0"
  property :char_name,          type: :string, limit: 250
  property :solar_system_id,    type: :integer, limit: 8 , default: "0"
  property :solar_system_name,  type: :string, limit: 255, default: ""
  property :constellation_id,   type: :integer, limit: 8 , default: "0"
  property :constellation_name, type: :string, limit: 255, default: ""
  property :region_name,        type: :string, limit: 255, default: ""
  property :mismatched_dscan,   type: :boolean, default: "0"
  timestamps

  has_many :scan_results

  before_create :initialize_scan

  def initialize_scan
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def update_from_env(character)
    self.character_id = character.env["HTTP_EVE_CHARID"]
    self.char_name = character.env["HTTP_EVE_CHARNAME"]
    self.region_name = character.env["HTTP_EVE_REGIONNAME"]
    self.constellation_name = character.env["HTTP_EVE_CONSTELLATIONNAME"]
    self.solar_system_name = character.env["HTTP_EVE_SOLARSYSTEMNAME"]
  end

  def parse_text(t)
    return false if t.lines.size == 0
    if t.lines.first.split("\t").count == 3
      parse_dscan(t)
      return true
    elsif t.lines.first.split("\t").count >= 7
      return false if scan_results.count > 0 and self.scan_type != "Fleet"
      self.scan_type="Fleet"
      self.save
      parse_fleet(t)
      return true
    elsif t.lines.first.split("\t").count == 1
      parse_local(t)
      return true
    end

    return false
  end

  def parse_dscan(t)
    t.lines.each {|line|
      line_items = line.split("\t")
      next if line_items.size == 0
      next if ScanResult.where(:scan_type => "DScan", :scan_id => id, :raw_name => line_items[0], :item_type_name => line_items[1]).count > 0
      sr = ScanResult.create(:scan_type => "DScan", :scan_id => id, :raw_name => line_items[0], :item_type_name => line_items[1]) 

      if (line_items[0].include?("Moon") and line_items[1]=="Moon") or (line_items[0].include?("- Star") and line_items[1].include?("Sun"))
        system_split = line_items[0].split(" ")
        self.mismatched_dscan = true if system_split[0] != self.solar_system_name
        self.solar_system_name = system_split[0]
        self.save
      end

      if line_items[2].strip != "-"
        line_items[2] = line_items[2].gsub(" km",'').strip

        if line_items[2].include?("AU")
          line_items[2] = line_items[2].gsub(" AU",'').strip.to_i * AU_TO_KM          
        end

        sr.distance = line_items[2]
      end
      item = Eve::InvType.where(:name => line_items[1]).first
      if item and item.eve_group
        sr.item_type_id = item.id
        sr.item_type_name = item.name
        sr.item_group_id = item.eve_group.id
        sr.item_group_name = item.eve_group.name
        sr.eve_category_id = item.eve_group.eve_category_id
      end
      sr.save
    }
  end

  def parse_local(t)
    t.lines.each {|line|
      line = line.strip
      next if line == ""
      next if ScanResult.where(:scan_type => "Local", :scan_id => id, :char_name => line.strip).count > 0
      sr = ScanResult.create(:scan_type => "Local", :scan_id => id, :char_name => line.strip)
      c = Character.where(:char_name => line.strip).first
      if c
        sr.character_id = c.id
        sr.alliance_id = c.alliance_id
        sr.alliance_name = c.alliance_name
      else
        Resque.enqueue ImportCharacterByNameJob, line, {:scan_result_id => sr.id}
      end
      sr.save
    }
  end

  def parse_fleet(t)
    t.lines.each {|line|
      line_items = line.split("\t")
      next if line_items.size == 0
      sr = ScanResult.where(:scan_type => "Fleet",:scan_id => id, :char_name => line_items[0]).first
      sr ||= ScanResult.create(:scan_type => "Fleet",:scan_id => id, :char_name => line_items[0], :solar_system_name => line_items[1], :item_type_name => line_items[2], :item_group_name => line_items[3], :fleet_role => line_items[4], :fleet_skills => line_items[5], :fleet_position => line_items[6])
      item = Eve::InvType.where(:name => line_items[2]).first
      if item and item.eve_group
        sr.item_type_id = item.id
        sr.item_type_name = item.name
        sr.item_group_id = item.eve_group.id
        sr.item_group_name = item.eve_group.name
        sr.eve_category_id = item.eve_group.eve_category_id
      end
      c = Character.where(:char_name => line_items[0]).first
      if c
        sr.character_id = c.id
        sr.alliance_id = c.alliance_id
        sr.alliance_name = c.alliance_name
      end
      sr.save
    }
  end
end
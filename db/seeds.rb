# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.count > 0
  puts "Database already seeded"
  exit
end

User.create(:username => "user", :password => "password", :email => "littlephsh@gmail.com")
Role.create(:name => "Admin")
Role.create(:name => "Troika")
Role.create(:name => "Military Advisor")
Role.create(:name => "Scout Commander")
Role.create(:name => "Corp Leadership")
Role.create(:name => "Fleet Commander")
Role.create(:name => "Scout")
Role.create(:name => "Razor Member")

u = User.first
Role.all.each {|r| u.add_role r.name}
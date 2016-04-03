# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# env :MAILTO, ''

my_env = Rails.env
job_type :resque, "curl -d k=:keycode&j=:task :app_url/api/v1/cron/ :output"

if my_env == "production"
  set :app_url, "http://app.eve-razor.com"
elsif my_env =~ /dev|test/
  set :app_url, "http://localhost:3000"
else
  set :app_url, "http://app.eve-razor.com"
end

set :keycode, "vmEAzt6XmrOkT3sA"

every 1.hours do
  resque "ImportZkillboardWatchlistJob"
end

every 6.hours do
  resque "CleanupImportedPapJob"
end

every 1.hours do
  resque "UpdateApiKeysJob"
end

every 5.minutes do
  resque "CloseFleetsJob"  
end

every 30.minutes do
  resque "ImportLocatorAgentNotificationsJob"
end

every 3.hours do 
  resque "FleetsUpdateRolesJob"
end

every 3.hours do 
  resque "ExportMembersCsvJob"
end

every 3.hours do
  resque "ExportFcCsvJob"
end

every 1.month do
  resque "ExportLastMonthsCsvJob"
end
namespace :db do
  task :autoupgrade => :environment do
    Dir[Rails.root + 'app/models/**/*.rb'].each { |path| require path }
    ActiveRecord::Base.auto_upgrade!
  end
end
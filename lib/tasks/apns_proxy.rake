namespace :apns_proxy do

  desc 'Deliver notifications from the cache to APNS'
  task :worker => :environment do
    ApnsProxy::Worker.new.run
  end

  desc 'Tidy notifications'
  task :tidy_notifications => :environment do
    Notification.tidy
  end

  desc 'Setup the initial admin user'
  task :setup => :environment do
    if User.all.empty?
      User.create(:name => 'Admin User', :email_address => 'admin@example.com', :username => 'admin', :password => 'password', :password_confirmation => 'password')
      puts
      puts "    A default admin user has been created with the following details:"
      puts
      puts "    Username...: #{'admin'.green}"
      puts "    Password...: #{'password'.green}"
      puts
    else
      puts "Your database already has users in it therefore there's no need to setup."
    end
  end

end

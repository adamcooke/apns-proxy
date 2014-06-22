namespace :apns_proxy do
  
  desc 'Deliver notifications from the cache to APNS'
  task :worker => :environment do
    ApnsProxy::Worker.run
  end
  
end

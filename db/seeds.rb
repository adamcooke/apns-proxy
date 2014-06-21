# Application
application = Application.create!(:name => "Sirportly")

# Environment
debug = application.environments.create!(:name => "Debug", :certificate => 'demo')
beta = application.environments.create!(:name => "Beta", :certificate => 'demo')
release = application.environments.create!(:name => "Release", :certificate => 'demo')

# Auth keys
application.auth_keys.create!(:name => "Test Debug Key", :environment => debug)
application.auth_keys.create!(:name => "Test Beta Key", :environment => beta)
application.auth_keys.create!(:name => "Test Release Key", :environment => release)

# User
User.create!(:name => 'Adam Cooke', :username => 'adam', :email_address => 'me@adamcooke.io', :password => 'password', :password_confirmation => 'password')
Authie::TwoFactor.configure do |config|
  config.encryption_key = ENV['TWO_FACTOR_ENCRYPTION_KEY']
end

AuthorizedNetworks.configure do |config|

  if ENV['AUTHORIZED_NETWORKS'].to_s == "__FILE__"
    # If it's set to __FILE__, just use the default configuration.

  elsif ENV['AUTHORIZED_NETWORKS'].is_a?(String)
    # An array of networks has been provided in an environment variable
    config.networks = ENV['AUTHORIZED_NETWORKS'].split(/\s*\,\s*/)

  else
    # If no AUTHORIZED_NETWORKS environment variable is provided.
    # We'll just disable all authorized network checking.
    config.disable!
  end

end

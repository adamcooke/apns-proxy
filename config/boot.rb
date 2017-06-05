# Set up gems listed in the Gemfile.
File.umask(2)
$stdout.sync = true
$stderr.sync = true
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

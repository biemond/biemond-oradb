source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 4.3']


gem 'coveralls', :require => false
gem 'simplecov', :require => false
gem 'simplecov-console', :require => false
gem 'codeclimate-test-reporter', :require => false

gem 'rspec-puppet-utils', :git => 'https://github.com/Accuity/rspec-puppet-utils.git'
gem 'hiera-puppet-helper', :git => 'https://github.com/bobtfish/hiera-puppet-helper.git'

gem 'semantic_puppet'
gem 'puppet-lint'

gem 'rake', '< 11.0'
gem 'puppet', '4.8.2' #puppetversion
gem 'rspec-puppet'
gem 'rspec-system-puppet'
gem 'puppetlabs_spec_helper'
gem 'puppet-syntax'
#gem 'facter', '>= 1.6.10'
gem 'ci_reporter_rspec'
gem 'rubocop', :git => 'https://github.com/bbatsov/rubocop',  :require => false
gem 'puppet-blacksmith'
#gem 'fog', '>= 1.25.0'
#gem 'fog-google', '= 0.1.0'
#gem 'tins', '= 1.6.0'
gem 'puppet-strings'
require 'rspec-puppet-utils'
# if your using puppet4, the following gem seems to causes issues
require 'hiera-puppet-helper'

require 'simplecov'
require 'coveralls'
require 'simplecov-console'


Coveralls.wear!

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do

  add_group "Puppet Types", '/lib/puppet/type/'
  add_group "Puppet Providers", '/lib/puppet/provider/'
  add_group "Puppet Functions", 'lib/puppet/parser/functions/'
  add_group "Facts", 'lib/facter'

  add_filter '/spec'
  add_filter '/.vendor/'

  # track_files 'lib/**/*.rb'
end

require 'puppetlabs_spec_helper/module_spec_helper'

if ENV['DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end

support_path = File.expand_path(File.join(File.dirname(__FILE__), '..','spec/support/*.rb'))
Dir[support_path].each {|f| require f}

def param_value(subject, type, title, param)
    subject.resource(type, title).send(:parameters)[param.to_sym]
end

RSpec.configure do |c|
    c.formatter = 'documentation'
    c.mock_with :rspec
    c.config = '/doesnotexist'
end
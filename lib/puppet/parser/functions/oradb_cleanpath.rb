require 'pathname'
module Puppet::Parser::Functions
  newfunction(:oradb_cleanpath, :type => :rvalue) do |args|
    raise Puppet::ParseError, "oradb_cleanpath requires exactly 1 argument" unless args.count == 1
    raise Puppet::ParseError, "oradb_cleanpath requires a string argument"  unless args[0].is_a? String
    path = Pathname.new(args[0])
    path.cleanpath.to_s
  end
end

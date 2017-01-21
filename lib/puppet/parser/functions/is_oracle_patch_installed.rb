module Puppet::Parser::Functions
  newfunction(:is_oracle_patch_installed, :type => :rvalue, :doc => <<-EOS
  Takes 2 parameters, the oracle_home and the patch_id.
  Returns true if the patch_id is installed in the oracle_home.
EOS
             ) do |args|
    raise(Puppet::ParseError, 'is_oracle_patch_installed(): Wrong number of arguments') unless args.size == 2

    oracle_home = args[0]
    raise(Puppet::ParseError, 'oracle_home must be absolute path') unless function_is_absolute_path([oracle_home])

    patch_id = args[1]
    raise(Puppet::ParseError, 'patch_id must be a string')           unless patch_id.is_a?(String)
    raise(Puppet::ParseError, 'patch_id must be a string of digits') unless patch_id =~ /^\d+$/

    patches = lookupvar('opatch_patches')
    return false if patches.nil?
    return false unless patches.key?(oracle_home)
    return true if patches[oracle_home].find { |h| h['patch_id'] == patch_id }
    return false
  end
end
begin
  require 'puppet/util/log'

  # restart the puppetmaster when changed
  module Puppet
    module Parser
      module Functions
        newfunction(:opatch_version, :type => :rvalue) do |args|
          oracle_homeArg = args[0].strip.downcase
          oracle_home = oracle_homeArg.gsub('/', '_').gsub('\\', '_').gsub('c:', '_c').gsub('d:', '_d').gsub('e:', '_e')

          log "lookup fact oradb_inst_opatch#{oracle_home}"
          # check the oracle home opatch
          found = lookup_db_var("oradb_inst_opatch#{oracle_home}")
          log "found value #{found}"
          return found
        end
      end
    end
  end

  def lookup_db_var(name)
    # puts "lookup fact "+name
    if db_var_exists(name)
      return lookupvar(name).to_s
    end
    'empty'
  end

  def db_var_exists(name)
    # puts "lookup fact "+name
    if lookupvar(name) != :undefined
      if lookupvar(name).nil?
        # puts "return false"
        return false
      end
      return true
    end
    # puts "not found"
    false
  end

  def log(msg)
    Puppet::Util::Log.create(
      :level   => :info,
      :message => msg,
      :source  => 'opatch_version'
    )
  end
end

begin
  require 'puppet/util/log'

  # restart the puppetmaster when changed
  module Puppet::Parser::Functions
    newfunction(:oracle_exists, :type => :rvalue) do |args|

      ora = lookup_db_var('oradb_inst_products')
      log "oracle_exists #{ora}"

      if ora == 'empty' or ora == 'NotFound'
        log 'oracle_exists return empty -> false'
        return false
      else
        software = args[0].strip
        log "oracle_exists compare #{ora} with #{software}"
        if ora.include? software
          log 'oracle_exists return true'
          return true
        end
      end
      log 'oracle_exists return false'
      return false

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
      :source  => 'oracle_exists'
    )
  end

end

# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:oracle_exists, :type => :rvalue) do |args|

    ora = lookupDbVar('oradb_inst_products')

    if ora == "empty"
      return false
    else
      software = args[0].strip
      if ora.include? software
        return true
      end
    end

    return false

  end
end

def lookupDbVar(name)
  #puts "lookup fact "+name
  if dbVarExists(name)
    return lookupvar(name).to_s
  end
  return "empty"
end


def dbVarExists(name)
  #puts "lookup fact "+name
  if lookupvar(name) != :undefined
    if lookupvar(name).nil?
      #puts "return false"
      return false
    end
    return true 
  end
  #puts "not found"
  return false 
end   

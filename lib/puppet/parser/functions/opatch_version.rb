# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:opatch_version, :type => :rvalue) do |args|
    
    oracleHomeArg = args[0].strip.downcase
    oracleHome    = oracleHomeArg.gsub("/","_").gsub("\\","_").gsub("c:","_c").gsub("d:","_d").gsub("e:","_e")

    # check the oracle home opatch
    lookupDbVar("ora_inst_opatch#{oracleHome}")
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
    return true
  end
  return false 
end   


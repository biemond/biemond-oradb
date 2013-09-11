# restart the puppetmaster when changed
module Puppet::Parser::Functions
  newfunction(:opatch_version, :type => :rvalue) do |args|
    
    oracleHomeArg = args[0].strip.downcase
    oracleHome    = oracleHomeArg.gsub("/","_").gsub("\\","_").gsub("c:","_c").gsub("d:","_d").gsub("e:","_e")

    # check the oracle home opatch
    if lookupvar("ora_inst_opatch#{oracleHome}") != :undefined
      return lookupvar("ora_inst_opatch#{oracleHome}")
    end
  end
end

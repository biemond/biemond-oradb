# oracle_database_homes.rb
require 'rexml/document' 

def get_opatch_patches(name)

    os = Facter.value(:operatingsystem)

    if ["CentOS", "RedHat","OracleLinux","Ubuntu","Debian","SLES"].include?os
      output3 = Facter::Util::Resolution.exec("su -l oracle -c \""+name+"/OPatch/opatch lsinventory -patch_id -oh "+name+" -invPtrLoc /etc/oraInst.loc\"")
    elsif ["Solaris"].include?os
      output3 = Facter::Util::Resolution.exec("su - oracle -c \""+name+"/OPatch/opatch lsinventory -patch_id -oh "+name+" -invPtrLoc /var/opt/oraInst.loc\"")
    elsif ["windows"].include?os
      output3 = Facter::Util::Resolution.exec("C:\\Windows\\System32\\cmd.exe /c "+name+"/OPatch/opatch.bat lsinventory -patch_id -oh " + name)
    end

    opatches = "Patches;"
    if output3.nil?
      opatches = "Error;"
    else 
      output3.each_line do |li|
        opatches += li[5, li.index(':')-5 ].strip + ";" if (li['Patch'] and li[': applied on'] )
      end
    end
   
    return opatches
end  

def get_opatch_version(name)

    os = Facter.value(:operatingsystem)

    if ["CentOS", "RedHat","OracleLinux","Ubuntu","Debian","SLES"].include?os
      opatchOut = Facter::Util::Resolution.exec("su -l oracle -c \""+name+"/OPatch/opatch version\"")
    elsif ["Solaris"].include?os
      opatchOut = Facter::Util::Resolution.exec("su - oracle -c \""+name+"/OPatch/opatch version\"")
    elsif ["windows"].include?os
      opatchOut = Facter::Util::Resolution.exec("C:\\Windows\\System32\\cmd.exe /c "+name+"/OPatch/opatch.bat version")

    end

    if opatchOut.nil?
      opatchver = "Error;"
    else 
      opatchver = opatchOut.split(" ")[2]
    end

    return opatchver
end

def get_orainst_loc()
  os = Facter.value(:operatingsystem)
  if ["CentOS", "RedHat","OracleLinux","Ubuntu","Debian","SLES"].include?os
    if FileTest.exists?("/etc/oraInst.loc")
      str = ""
      output = File.read("/etc/oraInst.loc")
      output.split(/\r?\n/).each do |item|
        if item.match(/^inventory_loc/)
          str = item[14,50]
        end
      end
      return str
    else
      return "NotFound"
    end
  elsif ["Solaris"].include?os
    if FileTest.exists?("/var/opt/oraInst.loc")
      str = ""
      output = File.read("/var/opt/oraInst.loc")
      output.split(/\r?\n/).each do |item|
        if item.match(/^inventory_loc/)
          str = item[14,50]
        end
      end
      return str
    else
      return "NotFound"
    end
  elsif ["windows"].include?os
    return "C:/Program Files/Oracle/Inventory"
  end
end


def get_orainst_products(path)
  unless path.nil?
    if FileTest.exists?(path+"/ContentsXML/inventory.xml")
      file = File.read( path+"/ContentsXML/inventory.xml" )
      doc = REXML::Document.new file
      software =  ""
      doc.elements.each("/INVENTORY/HOME_LIST/HOME") do |element|
      	str = element.attributes["LOC"]
      	unless str.nil? 
          software += str + ";"
          if str.include? "plugins"
            #skip EM agent
          elsif str.include? "agent"
            #skip EM agent 
          elsif str.include? "OraPlaceHolderDummyHome"
            #skip EM agent
          else
         	  home = str.gsub("/","_").gsub("\\","_").gsub("c:","_c").gsub("d:","_d").gsub("e:","_e")
         	  output = get_opatch_patches(str)
            Facter.add("ora_inst_patches#{home}") do
              setcode do
                output
              end
            end
            opatchver = get_opatch_version(str)
            Facter.add("ora_inst_opatch#{home}") do
              setcode do
                opatchver
              end
            end
          end
        end    
      end
      return software
    else
      return "NotFound"
    end
  else
    return "NotFound" 
  end
end

# get orainst loc data
inventory = get_orainst_loc
Facter.add("ora_inst_loc_data") do
  setcode do
    inventory
  end
end

# get orainst products
inventory2 = get_orainst_products(inventory)
Facter.add("ora_inst_products") do
  setcode do
    inventory2
  end
end

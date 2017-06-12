# oracle_database_homes.rb
require 'rexml/document'
require 'facter'

def get_database_user
  databaseUser = Facter.value('override_database_user')
  if databaseUser.nil?
    # puts "database user is oracle"
  else
    # puts "database user is " + databaseUser
    return databaseUser
  end
  'oracle'
end

def get_su_command
  os = Facter.value(:kernel)
  if 'Linux' == os
    return 'su -l '
  elsif 'SunOS' == os
    return 'su - '
  end
  'su -l '
end

def get_ora_inv_path
  os = Facter.value(:kernel)
  if 'Linux' == os
    return '/etc'
  elsif 'SunOS' == os
    return '/var/opt/oracle'
  end
  '/etc'
end

def get_opatch_version(name)
  opatchOut = Facter::Util::Resolution.exec(name + '/OPatch/opatch version')

  if opatchOut.nil?
    opatchver = 'Error;'
  else
    opatchver = opatchOut.split(' ')[2]
  end
  Puppet.debug "oradb opatch #{opatchver}"
  opatchver
end

def get_opatch_patches(name)
  opatch_out = Facter::Util::Resolution.exec(get_su_command + get_database_user + ' -c "' + name + '/OPatch/opatch lspatches"')
  return nil if opatch_out.nil?

  opatch_out.each_line.collect do |line|
    next unless line =~ /^\d+;/
    # Puppet.info "-patches- #{line}"
    split_line = line.split(';')
    { 'patch_id' => split_line[0], 'patch_desc' => (split_line[1] && split_line[1].chomp) }
  end.compact
end

def get_orainst_loc
  if FileTest.exists?(get_ora_inv_path + '/oraInst.loc')
    str = ''
    output = File.read(get_ora_inv_path + '/oraInst.loc')
    output.split(/\r?\n/).each do |item|
      if item.match(/^inventory_loc/)
        str = item[14, 50]
      end
    end
    return str
  else
    return nil
  end
end

def get_orainst_products(path)
  unless path.nil?
    if FileTest.exists?(path + '/ContentsXML/inventory.xml')
      file = File.read(path + '/ContentsXML/inventory.xml')
      doc = REXML::Document.new file
      software = ''
      patches_fact = {}
      doc.elements.each('/INVENTORY/HOME_LIST/HOME') do |element|
        str = element.attributes['LOC']
        unless str.nil?
          software += str + ';'
          if str.include? 'plugins'
            # skip EM agent
          elsif str.include? 'agent'
            # skip EM agent
          elsif str.include? 'OraPlaceHolderDummyHome'
            # skip EM agent
          else
            home = str.gsub('/', '_').gsub("\\", '_').gsub('c:', '_c').gsub('d:', '_d').gsub('e:', '_e')
            opatchver = get_opatch_version(str)
            Facter.add("oradb_inst_opatch#{home}") do
              setcode do
                opatchver
              end
            end

            patches = get_opatch_patches(str)
            # Puppet.info "-patches hash- #{patches}"
            patches_fact[str] = patches unless patches.nil?
          end
        end
      end
      Facter.add('opatch_patches') do
        # Puppet.info "-all patches hash- #{patches_fact}"
        setcode { patches_fact }
      end
      return software
    else
      return 'NotFound'
    end
  else
    return 'NotFound'
  end
end

# get orainst loc data
inventory = get_orainst_loc
Facter.add('oradb_inst_loc_data') do
  setcode do
    inventory
  end
end

# get orainst products
inventory2 = get_orainst_products(inventory)
Facter.add('oradb_inst_products') do
  setcode do
    inventory2
  end
end

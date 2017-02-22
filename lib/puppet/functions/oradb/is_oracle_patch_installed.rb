require 'puppet/util/log'
# check is Oracle patch is already installed
Puppet::Functions.create_function(:'oradb::is_oracle_patch_installed') do

  # check is Oracle patch is already installed
  # @param oracle_home_path full path to the oracle home directory
  # @param patch_id the patch id number
  # @return [Boolean] Return if it is found or not
  # @example is_oracle_patch_installed
  #   oradb::is_oracle_patch_installed('/opt/oracle/db/','1111') => true
  dispatch :is_oracle_patch_installed do
    param 'String', :oracle_home_path
    param 'String', :patch_id
    # return_type 'Boolean'
  end

  def is_oracle_patch_installed(oracle_home_path, patch_id)
    log 'start of function'
    scope = closure_scope
    patches = scope['facts']['opatch_patches']
    if patches == 'NotFound' or patches.nil?
      log 'return false opatch_patches is empty'
      return false
    end  
    if patches.key?(oracle_home_path)
      found = patches[oracle_home_path].find { |h| h['patch_id'] == patch_id }
      log("#{oracle_home_path} check for #{patch_id} found #{found}")
      return true if found
      return false
    else
      log("#{oracle_home_path} not found in patches facts, return false")
      return false
    end  
    log 'end of function return false'
    return false
  end

  def log(msg)
    Puppet::Util::Log.create(
      :level   => :info,
      :message => msg,
      :source  => 'oradb::is_oracle_patch_installed'
    )
  end

end

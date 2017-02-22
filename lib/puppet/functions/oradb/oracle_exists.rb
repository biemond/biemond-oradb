require 'puppet/util/log'
# Check if the oracle software already exists on the vm
Puppet::Functions.create_function(:'oradb::oracle_exists') do

  # Check if the oracle software already exists on the vm
  # @param oracle_home_path the full path to the oracle home directory
  # @return [Boolean] Return if it is found or not
  # @example Finding an Oracle product
  #   oradb::oracle_exists('/opt/oracle/db') => true
  dispatch :exists do
    param 'String', :oracle_home_path
    # return_type 'Boolean'
  end

  def exists(oracle_home_path)
    art_exists = false
    oracle_home_path = oracle_home_path.strip
    log "full oracle home path #{oracle_home_path}"

    # check the oracle products
    scope = closure_scope
    products = scope['facts']['oradb_inst_products']
    log "total oracle products #{products}"
    if products == 'NotFound' or products.nil?
      return art_exists
    else
      log "find #{oracle_home_path} inside #{products}"
      if products.include? oracle_home_path
        log 'found return true'
        return true
      end
    end
    log 'end of function return false'
    return art_exists

  end

  def log(msg)
    Puppet::Util::Log.create(
      :level   => :info,
      :message => msg,
      :source  => 'oradb::oracle_exists'
    )
  end
end

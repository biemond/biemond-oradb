Puppet::Type.type(:db_control).provide(:db_control) do

  def self.instances
    []
  end

  def instance_control(action)
    Puppet.debug "instance action: #{action}"

    name        = resource[:instance_name]
    oracle_home = resource[:oracle_product_home_dir]
    user        = resource[:os_user]

    if action == :start
      instance_action = 'startup'
    else
      instance_action = 'shutdown immediate'
    end

    command = "sqlplus /nolog <<-EOF
connect / as sysdba
#{instance_action}
EOF"

    Puppet.info "instance action: #{action} with command #{command}"
    output = `su - #{user} -c 'export ORACLE_HOME="#{oracle_home}";export PATH="#{oracle_home}/bin:$PATH";export ORACLE_SID="#{name}";export LD_LIBRARY_PATH="#{oracle_home}/lib";#{command}'`
    Puppet.info "instance result: #{output}"

    result = false
    output.each_line do |li|
      unless li.nil?
        if li.include? 'Database opened' or li.include? 'ORACLE instance shut down'
          result = true
        end
      end
    end
    fail(output) if result == false
  end

  def instance_status
    name           = resource[:instance_name]

    if :kernel == 'SunOS'
      command  = "/usr/ucb/ps wwxa | grep -v grep | /bin/grep 'ora_smon_#{name}'"
    else
      command  = "/bin/ps -ef | grep -v grep | /bin/grep 'ora_smon_#{name}'"
    end

    Puppet.debug "instance_status #{command}"
    output = `#{command}`

    output.each_line do |li|
      unless li.nil?
        Puppet.debug "line #{li}"
        if li.include? name
          Puppet.debug 'found instance'
          return 'Found'
        end
      end
    end
    'NotFound'
  end

  def start
    instance_control :start
  end

  def stop
    instance_control :stop
  end

  def restart
    instance_control :stop
    instance_control :start
  end

  def status
    output  = instance_status
    Puppet.debug "instance_status output #{output}"
    if output == 'Found'
      return :start
    else
      return :stop
    end
  end
end

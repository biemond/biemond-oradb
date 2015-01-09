Puppet::Type.type(:db_listener).provide(:db_listener) do

  def self.instances
    []
  end

  def listener_control(action)
    Puppet.debug "listener action: #{action}"

    oracleHome = resource[:oracle_home_dir]
    oracleBase = resource[:oracle_base_dir]
    user       = resource[:os_user]

    if action == :start
      listener_action = 'start'
    else
      listener_action = 'stop'
    end

    command = "#{oracleHome}/bin/lsnrctl #{listener_action}"

    Puppet.info "listener action: #{action} with command #{command}"

    output = `su - #{user} -c 'export ORACLE_HOME="#{oracleHome}";export ORACLE_BASE="#{oracleBase}";export LD_LIBRARY_PATH="#{oracleHome}/lib";cd #{oracleHome};#{command}'`
    Puppet.info "listener result: #{output}"
  end

  def listener_status
    oracleHome = resource[:oracle_home_dir]

    kernel = Facter.value(:kernel)

    ps_bin = (kernel != 'SunOS' || (kernel == 'SunOS' && Facter.value(:kernelrelease) == '5.11')) ? '/bin/ps' : '/usr/ucb/ps'
    ps_arg = kernel == 'SunOS' ? 'awwx' : '-ef'

    command  = "#{ps_bin} #{ps_arg} | /bin/grep -v grep | /bin/grep '#{oracleHome}/bin/tnslsnr'"

    Puppet.debug "listener_status #{command}"
    output = `#{command}`

    output.each_line do |li|
      unless li.nil?
        Puppet.debug "line #{li}"
        if li.include? "#{oracleHome}/bin/tnslsnr"
          Puppet.debug 'found listener'
          return 'Found'
        end
      end
    end
    'NotFound'
  end

  def start
    listener_control :start
  end

  def stop
    listener_control :stop
  end

  def restart
    listener_control :stop
    listener_control :start
  end

  def status
    output  = listener_status
    Puppet.debug "listener_status output #{output}"
    if output == 'Found'
      return :start
    else
      return :stop
    end
  end
end

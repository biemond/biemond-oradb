Puppet::Type.type(:db_listener).provide(:db_listener) do
  def self.instances
    []
  end

  def listener_control(action)
    oracle_home   = resource[:oracle_home_dir]
    oracle_base   = resource[:oracle_base_dir]
    user         = resource[:os_user]
    listenername = resource[:listener_name]

    Puppet.debug "listener action: #{action} #{listenername}"

    listener_action = if action == :start
                        "start #{listenername}"
                      else
                        "stop #{listenername}"
                      end

    command = "#{oracle_home}/bin/lsnrctl #{listener_action}"

    Puppet.info "listener action: #{action} with command #{command}"

    output = `su - #{user} -c 'export ORACLE_HOME="#{oracle_home}";export ORACLE_BASE="#{oracle_base}";export LD_LIBRARY_PATH="#{oracle_home}/lib";cd #{oracle_home};#{command}'`
    Puppet.info "listener result: #{output}"
  end

  def listener_status
    oracle_home = resource[:oracle_home_dir]
    listenername = resource[:listener_name]

    kernel = Facter.value(:kernel)

    ps_bin = (kernel != 'SunOS' || (kernel == 'SunOS' && Facter.value(:kernelrelease) == '5.11')) ? '/bin/ps' : '/usr/ucb/ps'
    ps_arg = (kernel == 'SunOS') ? 'awwx' : '-ef'

    # command  = "#{ps_bin} #{ps_arg} | /bin/grep -v grep | /bin/grep '#{oracle_home}/bin/tnslsnr #{listenername}'"
    command  = "#{ps_bin} #{ps_arg} | /bin/grep -v grep | /bin/grep -w -i '#{listenername}'"

    Puppet.debug "listener_status #{command}"
    output = `#{command}`

    output.each_line do |li|
      next if li.nil?

      Puppet.debug "line #{li}"
      if li.include? "#{oracle_home}/bin/tnslsnr"
        Puppet.debug 'found listener'
        return 'Found'
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
    output = listener_status
    Puppet.debug "listener_status output #{output}"
    return :start if output == 'Found'

    :stop
  end
end

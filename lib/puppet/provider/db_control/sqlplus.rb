Puppet::Type.type(:db_control).provide(:sqlplus, :parent => :base) do

#
  # This is bit of a hack. id is always root, but we need to declare a default provider
  #
  defaultfor :id => 'root'  


  def instance_control(action)
    Puppet.debug "instance action: #{action}"

    command, @succes_output = case action
    when :start
      ['startup', /Database opened/]
    when :stop
      ['shutdown immediate', /ORACLE instance shut down/]
    else
      fail "internal error unknown action #{action}"
    end

    Puppet.info "instance action: #{action} with command #{command}"
    @output = sql command
    if unsuccessful? 
      fail(@output) if unsuccessful?
    else
      Puppet.info "instance result: #{@output}"
    end
  end

  def status
    name = resource[:instance_name]

    kernel = Facter.value(:kernel)

    ps_bin = (kernel != 'SunOS' || (kernel == 'SunOS' && Facter.value(:kernelrelease) == '5.11')) ? '/bin/ps' : '/usr/ucb/ps'
    ps_arg = kernel == 'SunOS' ? 'awwx' : '-ef'

    command  = "#{ps_bin} #{ps_arg} | /bin/grep -v grep | /bin/grep 'ora_smon_#{name}'"

    Puppet.debug "instance_status #{command}"
    output = `#{command}`
    output.scan(/ora_smon_#{name}/).empty? ? :stop : :start
  end


  private

  def unsuccessful?
    @output.scan(@succes_output).empty?
  end

  def sql(command)
    name        = resource[:instance_name]
    oracle_home = resource[:oracle_product_home_dir]
    user        = resource[:os_user]
    command     = "sqlplus /nolog <<-EOF
connect / as sysdba
#{command}
EOF"
    `su - #{user} -c 'export ORACLE_HOME="#{oracle_home}";export PATH="#{oracle_home}/bin:$PATH";export ORACLE_SID="#{name}";export LD_LIBRARY_PATH="#{oracle_home}/lib";#{command}'`
  end

end

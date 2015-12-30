Puppet::Type.type(:db_control).provide(:srvctl, :parent => :base) do


  def instance_control(action)
    name        = resource[:instance_name]
    Puppet.debug "instance action: #{action} on instance type #{resource[:db_type]}"
    force = (action == :stop) ? '-f' : ''
    @output = case resource[:db_type]
    when :database
      srvctl "#{action} database -db #{name}"
    when :asm
      srvctl "#{action} asm #{force}"
    else
      fail "internal error unknown action #{action}"
    end
    if unsuccessful?
      fail @output
    else
      Puppet.debug @output if @output
    end
  end

  def status
    name        = resource[:instance_name]
    @output = case resource[:db_type]
    when :database
      srvctl "status database -db #{name}"
    when :asm
      srvctl "status asm"
    else
      fail "internal error unknown action #{action}"
    end
    if unsuccessful?
      fail @output
    end
    Puppet.debug @output
    @output.scan(/is running/).empty? ? :stop : :start
  end


  private

  def unsuccessful?
    !@output.scan(/failed/).empty?
  end


  def srvctl(command)
    oracle_home = resource[:oracle_product_home_dir]
    command =[
      "export ORACLE_HOME=#{oracle_home}",
      "export PATH=#{oracle_home}/bin:$PATH",
      "export LD_LIBRARY_PATH=#{oracle_home}/lib",
      "$ORACLE_HOME/bin/srvctl #{command}"
    ].join(';')
    Puppet.debug "instance_status #{command}"
    `#{command}`
  end

end

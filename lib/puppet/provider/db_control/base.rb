Puppet::Type.type(:db_control).provide(:base) do

  confine :true => false # This is NEVER a valid provider. It is just used as a base class

  def self.instances
    fail 'resource list not supported for db_control type'
  end

  def start
    instance_control :start
  end

  def stop
    instance_control :stop
  end
  
  def mount
    instance_control :mount
  end

  def restart
    instance_control :stop
    instance_control :start
  end

end

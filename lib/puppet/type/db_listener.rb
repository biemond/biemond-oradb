module Puppet
  newtype(:db_listener) do
    desc 'control the oracle db listener state like running,stop,restart'

    newproperty(:ensure) do
      desc 'Whether to do something.'

      newvalue(:start, :event => :listener_running) do
        unless :refreshonly == true
          provider.start
        end
      end

      newvalue(:stop, :event => :listener_stop) do
        unless :refreshonly == true
          provider.stop
        end
      end

      aliasvalue(:running, :start)
      aliasvalue(:abort, :stop)

      def retrieve
        provider.status
      end

      def sync
        event = super()

        if property = @resource.property(:enable)
          val = property.retrieve
          property.sync unless property.safe_insync?(val)
        end

        event
      end
    end

    newparam(:name) do
      desc <<-EOT
        The title.
      EOT
      isnamevar
    end

    newparam(:oracle_base_dir) do
      desc <<-EOT
        The oracle base folder.
      EOT
    end

    newparam(:oracle_home_dir) do
      desc <<-EOT
        The oracle home folder.
      EOT
    end

    newparam(:os_user) do
      desc <<-EOT
        The weblogic operating system user.
      EOT

      defaultto 'oracle'
    end

    newparam(:refreshonly) do
      desc <<-EOT
        The command should only be run as a
        refresh mechanism for when a dependent object is changed.
      EOT

      newvalues(:true, :false)

      defaultto :false
    end

    def refresh
      Puppet.info 'db_listener refresh'
      provider.restart
    end

  end
end

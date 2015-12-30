module Puppet
  Type::newtype(:db_control) do
    desc 'control the database instance state like running,stop,restart'

    newproperty(:ensure) do
      desc 'Whether to do something.'

      newvalue(:start, :event => :instance_running) do
        unless resource[:refreshonly] == :true
          provider.start
        end
      end

      newvalue(:stop, :event => :instance_stop) do
        unless resource[:refreshonly] == :true
          provider.stop
        end
      end

      aliasvalue(:running, :start)
      aliasvalue(:abort, :stop)
      aliasvalue(:stopped, :stop)

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

    newparam(:instance_name) do
      desc <<-EOT
        The database instance name.
      EOT
    end

    newparam(:db_type) do
      desc <<-EOT
        The type of instance.
      EOT

      defaultto(:database)
      newvalues(:database, :asm)
      aliasvalue(:grid, :asm)
    end

    newparam(:oracle_product_home_dir) do
      desc <<-EOT
        The oracle product home folder.
      EOT
    end

    newparam(:grid_product_home_dir) do
      desc <<-EOT
        The grid product home folder.
      EOT
    end

    newparam(:os_user) do
      desc <<-EOT
        The weblogic operating system user.
      EOT
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
      Puppet.info 'db_control refresh'
      provider.restart
    end

  end
end

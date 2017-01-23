require 'spec_helper'
require 'shared_contexts'

describe 'oradb::prepareautostart', :type => :class do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  
  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) {{
      :oracle_home => '/opt/oracle',
      :user => "oracle",
      :service_name => "oracle"
  }}


  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  describe 'Solaris' do
    let(:facts) {{
        :kernel => 'SunOS',
        :operatingsystem => 'Solaris'
    }}

    it do
      is_expected.to contain_file('/etc/oracle')
         .with(
           'ensure'  => 'present',
           'mode'    => '0755',
           'owner'   => 'root'
         )
    end
    it do
      is_expected.to contain_file('/tmp/oradb_smf.xml')
        .with(
          'ensure' => 'present',
          'mode'   => '0755',
          'owner'  => 'root',
          'content' => /\/etc\/oracle/
        )
    end

    it do
      is_expected.to contain_exec('enable service oracle')
        .with(
          'command'   => 'svccfg -v import /tmp/oradb_smf.xml',
          'user'      => 'root',
          'logoutput' => true,
          'path'      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
          'unless'    => 'svccfg list | grep oracledatabase',
          'require'   => ['File[/tmp/oradb_smf.xml]','File[/etc/oracle]'],
        )
    end
  end

  describe 'Linux' do
    let(:facts) do
      {:kernel => 'Linux', :operatingsystem => 'RedHat'}
    end

    it do
      is_expected.to contain_file('/etc/init.d/oracle')
         .with(
           'content' => /LOCK_FILE=\/var\/lock\/subsys\/oracle/,
           'ensure'  => 'present',
           'mode'    => '0755',
           'owner'   => 'root'
         )
    end
    rhel_based = ['CentOS', 'RedHat', 'OracleLinux', 'SLES']
    deb_based = ['Ubuntu', 'Debian']
    rhel_based.each do |os|
      describe os do
        let(:facts) do
          {

            :kernel => 'Linux',
            :operatingsystem => os
          }

        end

        it do
          is_expected.to contain_exec('enable service oracle')
             .with(
               'command'   => "chkconfig --add oracle",
               'require'   => 'File[/etc/init.d/oracle]',
               'user'      => 'root',
               'unless'    => "chkconfig --list | /bin/grep \'oracle\'",
               'path'      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
               'logoutput' => true,
             )
        end
      end
    end
    deb_based.each do |os|
      describe os do
        let(:facts) do
          {
            :kernel => 'Linux',
            :operatingsystem => os
          }

        end

        it do
          is_expected.to contain_exec('enable service oracle')
               .with(
                 'command'   => "update-rc.d oracle defaults",
                 'require'   => 'File[/etc/init.d/oracle]',
                 'user'      => 'root',
                 'unless'    => "ls /etc/rc3.d/*oracle | /bin/grep \'oracle\'",
                 'path'      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
                 'logoutput' => true,
               )
        end
      end
    end
  end
end

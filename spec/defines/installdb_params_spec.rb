require 'spec_helper'

describe 'oradb::installdb', :type => :define do

  describe "wrong db version" do
    let(:params){{
          :version                 => '10.2.0.4',
          :file                    => 'linuxamd64_10gR2_database',
          :database_type            => 'SE',
          :oracle_base              => '/oracle',
          :oracle_home              => '/oracle/product/10.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'10.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/10.2/db does not exists")
             }.to raise_error(Puppet::Error, /Unrecognized database install version, use 11.2.0.1|11.2.0.3|11.2.0.4|12.1.0.1|12.1.0.1/)
    end

  end


  describe "wrong db type" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :database_type            => 'XX',
          :oracle_base              => '/oracle',
          :oracle_home              => '/oracle/product/11.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /Unrecognized database type, please use EE|SE|SEONE/)
    end

  end

  describe "oracle_base error" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :database_type            => 'SE',
          :oracle_home              => '/oracle/product/11.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end

  describe "oracle_base error 2" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :database_type            => 'SE',
          :oracle_base              => 123,
          :oracle_home              => '/oracle/product/11.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /expects a String value, got Integer/)
    end

  end

  describe "oracle_home error" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :database_type            => 'SE',
          :oracle_base              => '/oracle',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end

  describe "oracle_home error 2" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :database_type            => 'SE',
          :oracle_base              => 123,
          :oracle_base              => '/oracle',
          :oracle_home              => 123,
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /expects a String value, got Integer/)
    end

  end

  describe "oracle_base and oracle_home error" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :database_type            => 'SE',
          :oracle_base              => '/oraclexxxx',
          :oracle_home              => '/oracle/product/11.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remote_file              => false,
          :zip_extract              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /oracle_home folder should be under the oracle_base folder/)
    end

  end

end

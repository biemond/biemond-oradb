require 'spec_helper'

describe 'oradb::database_pluggable', :type => :define do

  describe "wrong database version" do
    let(:params){{
         :ensure                   => 'present',
         :oracle_home_dir          => '/oracle/product/11.2/db',
         :version                  => '11.2',
         :user                     => 'oracle',
         :group                    => 'dba',
         :source_db                => 'orcl',
         :pdb_name                 => 'pdb1',
         :pdb_datafile_destination => '/aa/aaa',
         :pdb_admin_username       => 'pdb_adm',
         :pdb_admin_password       => 'Welcome01'
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /Unrecognized version, use 12.1/)
    end

  end

  describe "unknown action" do
    let(:params){{
         :ensure                   => 'xxx',
         :oracle_home_dir          => '/oracle/product/12.1/db',
         :version                  => '12.1',
         :user                     => 'oracle',
         :group                    => 'dba',
         :source_db                => 'orcl',
         :pdb_name                 => 'pdb1',
         :pdb_datafile_destination => '/aa/aaa',
         :pdb_admin_username       => 'pdb_adm',
         :pdb_admin_password       => 'Welcome01'
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /expects a match for Enum/)
    end

  end

  describe "create pdb 1" do
    let(:params){{
         :ensure                   => 'present',
         :oracle_home_dir          => '/oracle/product/12.1/db',
         :version                  => '12.1',
         :user                     => 'oracle',
         :group                    => 'dba',
         :source_db                => 'orcl',
         :pdb_name                 => 'pdb1',
         :pdb_admin_username       => 'pdb_adm',
         :pdb_admin_password       => 'Welcome01'
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end

  describe "create pdb 2" do
    let(:params){{
         :ensure                   => 'present',
         :oracle_home_dir          => '/oracle/product/12.1/db',
         :version                  => '12.1',
         :user                     => 'oracle',
         :group                    => 'dba',
         :source_db                => 'orcl',
         :pdb_name                 => 'pdb1',
         :pdb_datafile_destination => '/aa/aaa',
         :pdb_admin_username       => 'pdb_adm',
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end

  describe "create pdb 3" do
    let(:params){{
         :ensure                   => 'present',
         :oracle_home_dir          => '/oracle/product/12.1/db',
         :version                  => '12.1',
         :user                     => 'oracle',
         :group                    => 'dba',
         :source_db                => 'orcl',
         :pdb_datafile_destination => '/aa/aaa',
         :pdb_admin_username       => 'pdb_adm',
         :pdb_admin_password       => 'Welcome01'
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end

  describe "create pdb 4" do
    let(:params){{
         :ensure                   => 'present',
         :oracle_home_dir          => '/oracle/product/12.1/db',
         :version                  => '12.1',
         :user                     => 'oracle',
         :group                    => 'dba',
         :pdb_name                 => 'pdb1',
         :pdb_datafile_destination => '/aa/aaa',
         :pdb_admin_username       => 'pdb_adm',
         :pdb_admin_password       => 'Welcome01'
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end


  describe "drop pdb" do
    let(:params){{
         :ensure                   => 'absent',
         :oracle_home_dir          => '/oracle/product/12.1/db',
         :version                  => '12.1',
         :user                     => 'oracle',
         :group                    => 'dba',
         :source_db                => 'orcl',
         :pdb_name                 => 'pdb1',
         :pdb_admin_password       => 'Welcome01'
    }}
    let(:title) {'pdb1'}
    let(:facts) {{ :operatingsystem => 'CentOS',
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_exec("dbca pdb execute pdb1")
               }.to raise_error(Puppet::Error, /expects a String value, got Undef/)
    end

  end


end
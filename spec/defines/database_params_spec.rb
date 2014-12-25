require 'spec_helper'

describe 'oradb::database', :type => :define do

  describe "wrong database version" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.1',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'create',
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /Unrecognized version/)
    end

  end

  describe "wrong OS" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.2',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'create',
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'Windows' ,
                   :kernel          => 'Windows',
                   :osfamily        => 'Windows' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /Unrecognized operating system/)
    end

  end

  describe "wrong action" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.2',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'xxxxx',
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /Unrecognized database action/)
    end

  end

  describe "wrong databaseType" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.2',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'create',
                   :databaseType            => "XXXX",
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /Unrecognized databaseType/)
    end

  end

  describe "wrong emConfiguration" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.2',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'create',
                   :emConfiguration         => "XXXX",
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /Unrecognized emConfiguration/)
    end

  end

  describe "wrong storageType" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.2',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'create',
                   :storageType             => "XXXX",
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /Unrecognized storageType/)
    end

  end

  describe "container database on 11.2" do
    let(:params){{
                   :oracleBase              => '/oracle',
                   :oracleHome              => '/oracle/product/11.2/db',
                   :version                 => '11.2',
                   :user                    => 'oracle',
                   :group                   => 'dba',
                   :downloadDir             => '/install',
                   :action                  => 'create',
                   :containerDatabase       => true,
    }}
    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_file("/install/database_testDb_Create.rsp")
               }.to raise_error(Puppet::Error, /container or pluggable database is not supported on version 11.2/)
    end

  end


  describe "init params" do

    let(:title) {'testDb_Create'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}
    let(:base_params) {{
                         :oracleBase              => '/oracle',
                         :oracleHome              => '/oracle/product/11.2/db',
                         :version                 => '11.2',
                         :user                    => 'oracle',
                         :group                   => 'dba',
                         :downloadDir             => '/install',
                         :action                  => 'create'
    }}

    describe "specified as a String" do

      let(:params) { base_params.merge(:initParams=> "a=1,b=2") }

      it "should pass" do
        expect { should contain_file("/install/database_testDb_Create.rsp")
                 }.not_to raise_error()
      end

    end

    describe "specified as a Hash" do

      let(:params) { base_params.merge!(:initParams=> {'a' => 'a', 'b' => 'b'}) }

      it "should fail" do
        expect { should contain_file("/install/database_testDb_Create.rsp")
                 }.not_to raise_error()
      end
    end

    describe "specified as an Array" do

      let(:params) { base_params.merge(:initParams=> [1,2,3,4,5]) }

      it "should fail" do
        expect { should contain_file("/install/database_testDb_Create.rsp")
                 }.to raise_error(Puppet::Error, /initParams only supports a String or a Hash as value type/)
      end

    end

  end
end

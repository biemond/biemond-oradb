require 'spec_helper'

describe 'oradb::installdb', :type => :define do

  describe "wrong db version" do
    let(:params){{
          :version                 => '10.2.0.4',
          :file                    => 'linuxamd64_10gR2_database',
          :databaseType            => 'SE',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/10.2/db',
          :createUser              => true,
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remoteFile              => false,
          :zipExtract              => false,
          :downloadDir             => '/install',
          :puppetDownloadMntPoint  => '/software',
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

  describe "wrong O.S." do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :databaseType            => 'SE',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/11.2/db',
          :createUser              => true,
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remoteFile              => false,
          :zipExtract              => false,
          :downloadDir             => '/install',
          :puppetDownloadMntPoint  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'Windows' ,
                   :kernel          => 'Windows',
                   :osfamily        => 'Windows' }}

    it do
      expect { should contain_notify("oradb::installdb /oracle/product/11.2/db does not exists")
             }.to raise_error(Puppet::Error, /Unrecognized operating system, please use it on a Linux or SunOS host/)
    end       

 
  end

  describe "wrong db type" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'linuxamd64_11gR2_database',
          :databaseType            => 'XX',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/11.2/db',
          :createUser              => true,
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remoteFile              => false,
          :zipExtract              => false,
          :downloadDir             => '/install',
          :puppetDownloadMntPoint  => '/software',
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

end

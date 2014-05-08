require 'spec_helper'

describe 'oradb::installdb', :type => :define do

  describe "CentOS remote" do
    let(:params){{
          :version                 => '12.1.0.1',
          :file                    => 'linuxamd64_12c_database',
          :databaseType            => 'SE',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/12.1/db',
          :createUser              => true,
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remoteFile              => true,
          :zipExtract              => true,
          :downloadDir             => '/install',
          :puppetDownloadMntPoint  => '/software',
                }}
    let(:title) {'12.1.0.1_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}



    describe "oradb utils structure" do
      it do 
        should contain_oradb__utils__structure("oracle structure 12.1.0.1").with({
              'oracle_base_home_dir'  => '/oracle',
              'ora_inventory_dir'     => '/oracle/oraInventory',
              'os_user'               => 'oracle',
              'os_group'              => 'dba',
              'os_group_install'      => 'oinstall',
              'os_group_oper'         => 'oper',
              'user_base_dir'         => '/home',
              'create_user'           => 'true',
           })
      end
    end

    describe "oradb orainst" do
      it do 
        should contain_oradb__utils__orainst('database orainst 12.1.0.1').with({
             'ora_inventory_dir'  => '/oracle/oraInventory',
             'os_group'           => 'oinstall',
           })
      end
    end

    describe "oradb response file" do
      it do 
        should contain_file("/install/db_install_12.1.0.1.rsp").that_requires('Oradb::Utils::Orainst[database orainst 12.1.0.1]')
      end
    end

    describe "oradb file1" do
      it { 
           should contain_file("/install/linuxamd64_12c_database_1of2.zip").with({
             'source'  => '/software/linuxamd64_12c_database_1of2.zip',
           }).that_comes_before('Exec[extract /install/linuxamd64_12c_database_1of2.zip]').that_requires('Oradb::Utils::Structure[oracle structure 12.1.0.1]')    
         }  
    end

    describe "oradb extract file1" do
      it { 
           should contain_exec("extract /install/linuxamd64_12c_database_1of2.zip").with({
             'command'  => 'unzip -o /install/linuxamd64_12c_database_1of2.zip -d /install/linuxamd64_12c_database',
           }).that_requires('Oradb::Utils::Structure[oracle structure 12.1.0.1]')  
         }  
    end

    describe "oradb file2" do
      it do 
        should contain_file("/install/linuxamd64_12c_database_2of2.zip").with({
             'source'  => '/software/linuxamd64_12c_database_2of2.zip',
           }).that_comes_before('Exec[extract /install/linuxamd64_12c_database_2of2.zip]').that_requires('File[/install/linuxamd64_12c_database_1of2.zip]')  
      end
    end

    describe "oradb extract file2" do
      it { 
           should contain_exec("extract /install/linuxamd64_12c_database_2of2.zip").with({
             'command'  => 'unzip -o /install/linuxamd64_12c_database_2of2.zip -d /install/linuxamd64_12c_database',
           }).that_requires('Exec[extract /install/linuxamd64_12c_database_1of2.zip]')  
         }  
    end
  end

end

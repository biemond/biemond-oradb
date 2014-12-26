require 'spec_helper'

describe 'oradb::installdb', :type => :define do

  describe "CentOS remote" do
    let(:params){{
          :version                 => '12.1.0.1',
          :file                    => 'linuxamd64_12c_database',
          :databaseType            => 'SE',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/12.1/db',
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
        should contain_oradb__utils__dbstructure("oracle structure 12.1.0.1").with({
              'oracle_base_home_dir'  => '/oracle',
              'ora_inventory_dir'     => '/oracle/oraInventory',
              'os_user'               => 'oracle',
              'os_group_install'      => 'oinstall',
           })
      end
    end

    describe "oradb orainst" do
      it do
        should contain_oradb__utils__dborainst('database orainst 12.1.0.1').with({
             'ora_inventory_dir'  => '/oracle/oraInventory',
             'os_group'           => 'oinstall',
           })
      end
    end

    describe "oradb response file" do
      it do
        should contain_file("/install/db_install_12.1.0.1.rsp").that_requires('Oradb::Utils::Dborainst[database orainst 12.1.0.1]')
      end
    end

    describe "oradb file1" do
      it {
           should contain_file("/install/linuxamd64_12c_database_1of2.zip").with({
             'source'  => '/software/linuxamd64_12c_database_1of2.zip',
           }).that_comes_before('Exec[extract /install/linuxamd64_12c_database_1of2.zip]').that_requires('Oradb::Utils::Dbstructure[oracle structure 12.1.0.1]')
         }
    end

    describe "oradb extract file1" do
      it {
           should contain_exec("extract /install/linuxamd64_12c_database_1of2.zip").with({
             'command'  => 'unzip -o /install/linuxamd64_12c_database_1of2.zip -d /install/linuxamd64_12c_database',
           }).that_requires('Oradb::Utils::Dbstructure[oracle structure 12.1.0.1]')
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

    describe "oradb install database" do
      it {
           should contain_exec("install oracle database 12.1.0.1_Linux-x86-64").with({
             'command'  => "/bin/sh -c 'unset DISPLAY;/install/linuxamd64_12c_database/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /install/db_install_12.1.0.1.rsp'",
             'creates'  => "/oracle/product/12.1/db/dbs",
             'group'    => 'oinstall',
           }).that_requires('Oradb::Utils::Dborainst[database orainst 12.1.0.1]').that_requires('File[/install/db_install_12.1.0.1.rsp]')
         }
    end

    describe "oracle home" do
      it do
        should contain_file("/oracle/product/12.1/db").with({
             'ensure'  => 'directory',
             'owner'   => 'oracle',
             'group'   => 'oinstall',
           }).that_requires('Exec[install oracle database 12.1.0.1_Linux-x86-64]')
      end
    end

    describe "oracle bash_profile" do
      it do
        should contain_file("/home/oracle/.bash_profile").with({
             'owner'   => 'oracle',
             'group'   => 'dba',
           }).that_requires('Oradb::Utils::Dbstructure[oracle structure 12.1.0.1]')
      end
    end

    describe "exec root.sh" do
      it do
        should contain_exec("run root.sh script 12.1.0.1_Linux-x86-64").with({
             'command' => '/oracle/product/12.1/db/root.sh',
             'group'   => 'root',
           }).that_requires('Exec[install oracle database 12.1.0.1_Linux-x86-64]')
      end
    end

  end

  describe "CentOS local" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'p13390677_112040_Linux-x86-64',
          :databaseType            => 'SE',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/11.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remoteFile              => false,
          :zipExtract              => true,
          :downloadDir             => '/install',
          :puppetDownloadMntPoint  => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    describe "oradb utils structure" do
      it do
        should contain_oradb__utils__dbstructure("oracle structure 11.2.0.4").with({
              'oracle_base_home_dir'  => '/oracle',
              'ora_inventory_dir'     => '/oracle/oraInventory',
              'os_user'               => 'oracle',
              'os_group_install'      => 'oinstall',
           })
      end
    end

    describe "oradb orainst" do
      it do
        should contain_oradb__utils__dborainst('database orainst 11.2.0.4').with({
             'ora_inventory_dir'  => '/oracle/oraInventory',
             'os_group'           => 'oinstall',
           })
      end
    end

    describe "oradb response file" do
      it do
        should contain_file("/install/db_install_11.2.0.4.rsp").that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.4]')
      end
    end

    describe "oradb extract file1" do
      it {
           should contain_exec("extract /install/p13390677_112040_Linux-x86-64_1of7.zip").with({
             'command'  => 'unzip -o /software/p13390677_112040_Linux-x86-64_1of7.zip -d /install/p13390677_112040_Linux-x86-64',
           }).that_requires('Oradb::Utils::Dbstructure[oracle structure 11.2.0.4]')
         }
    end

    describe "oradb extract file2" do
      it {
           should contain_exec("extract /install/p13390677_112040_Linux-x86-64_2of7.zip").with({
             'command'  => 'unzip -o /software/p13390677_112040_Linux-x86-64_2of7.zip -d /install/p13390677_112040_Linux-x86-64',
           }).that_requires('Exec[extract /install/p13390677_112040_Linux-x86-64_1of7.zip]')
         }
    end

    describe "oradb install database" do
      it {
           should contain_exec("install oracle database 11.2.0.4_Linux-x86-64").with({
             'command'  => "/bin/sh -c 'unset DISPLAY;/install/p13390677_112040_Linux-x86-64/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /install/db_install_11.2.0.4.rsp'",
             'creates'  => "/oracle/product/11.2/db/dbs",
             'group'    => 'oinstall',
           }).that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.4]').that_requires('File[/install/db_install_11.2.0.4.rsp]')
         }
    end

    describe "oracle home" do
      it do
        should contain_file("/oracle/product/11.2/db").with({
             'ensure'  => 'directory',
             'owner'   => 'oracle',
             'group'   => 'oinstall',
           }).that_requires('Exec[install oracle database 11.2.0.4_Linux-x86-64]')
      end
    end

    describe "oracle bash_profile" do
      it do
        should contain_file("/home/oracle/.bash_profile").with({
             'owner'   => 'oracle',
             'group'   => 'dba',
           }).that_requires('Oradb::Utils::Dbstructure[oracle structure 11.2.0.4]')
      end
    end

    describe "exec root.sh" do
      it do
        should contain_exec("run root.sh script 11.2.0.4_Linux-x86-64").with({
             'command' => '/oracle/product/11.2/db/root.sh',
             'group'   => 'root',
           }).that_requires('Exec[install oracle database 11.2.0.4_Linux-x86-64]')
      end
    end

  end

  describe "CentOS unpacked" do
    let(:params){{
          :version                 => '11.2.0.3',
          :file                    => 'p10404530_112030_Linux-x86-64',
          :databaseType            => 'EE',
          :oracleBase              => '/oracle',
          :oracleHome              => '/oracle/product/11.2/db',
          :user                    => 'oracle',
          :group                   => 'dba',
          :group_install           => 'oinstall',
          :group_oper              => 'oper',
          :remoteFile              => false,
          :zipExtract              => false,
          :downloadDir             => '/mnt',
          :puppetDownloadMntPoint  => '/software',
                }}
    let(:title) {'11.2.0.3_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'OracleLinux' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    describe "oradb utils structure" do
      it do
        should contain_oradb__utils__dbstructure("oracle structure 11.2.0.3").with({
              'oracle_base_home_dir'  => '/oracle',
              'ora_inventory_dir'     => '/oracle/oraInventory',
              'os_user'               => 'oracle',
              'os_group_install'      => 'oinstall',
           })
      end
    end

    describe "oradb orainst" do
      it do
        should contain_oradb__utils__dborainst('database orainst 11.2.0.3').with({
             'ora_inventory_dir'  => '/oracle/oraInventory',
             'os_group'           => 'oinstall',
           })
      end
    end

    describe "oradb response file" do
      it do
        should contain_file("/mnt/db_install_11.2.0.3.rsp").that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.3]')
      end
    end

    describe "oradb install database" do
      it {
           should contain_exec("install oracle database 11.2.0.3_Linux-x86-64").with({
             'command'  => "/bin/sh -c 'unset DISPLAY;/mnt/p10404530_112030_Linux-x86-64/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /mnt/db_install_11.2.0.3.rsp'",
             'creates'  => "/oracle/product/11.2/db/dbs",
             'group'    => 'oinstall',
           }).that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.3]').that_requires('File[/mnt/db_install_11.2.0.3.rsp]')
         }
    end

    describe "oracle home" do
      it do
        should contain_file("/oracle/product/11.2/db").with({
             'ensure'  => 'directory',
             'owner'   => 'oracle',
             'group'   => 'oinstall',
           }).that_requires('Exec[install oracle database 11.2.0.3_Linux-x86-64]')
      end
    end

    describe "oracle bash_profile" do
      it do
        should contain_file("/home/oracle/.bash_profile").with({
             'owner'   => 'oracle',
             'group'   => 'dba',
           }).that_requires('Oradb::Utils::Dbstructure[oracle structure 11.2.0.3]')
      end
    end

    describe "exec root.sh" do
      it do
        should contain_exec("run root.sh script 11.2.0.3_Linux-x86-64").with({
             'command' => '/oracle/product/11.2/db/root.sh',
             'group'   => 'root',
           }).that_requires('Exec[install oracle database 11.2.0.3_Linux-x86-64]')
      end
    end

  end

end

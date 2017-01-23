require 'spec_helper'

describe 'oradb::installdb', :type => :define do

  describe "CentOS remote" do
    default_params = {
          :version                   => '12.1.0.1',
          :file                      => 'linuxamd64_12c_database',
          :database_type             => 'SE',
          :oracle_base               => '/u01/app/oracle',
          :oracle_home               => '/u01/app/oracle/product/12.1/db',
          :ora_inventory_dir         => '/u01/app',
          :user                      => 'oracle',
          :group                     => 'dba',
          :group_install             => 'oinstall',
          :group_oper                => 'oper',
          :remote_file               => true,
          :zip_extract               => true,
          :download_dir              => '/install',
          :puppet_download_mnt_point => '/software' }
    let(:params) { default_params }
    let(:title) {'12.1.0.1_Linux-x86-64'}
    default_facts = { :operatingsystem => 'CentOS',
                      :kernel          => 'Linux',
                      :osfamily        => 'RedHat' }
    let(:facts) { default_facts }
    context 'with no oradb_inst_loc_data fact' do
      describe "oradb utils structure" do
        it do
          should contain_db_directory_structure("oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64").with({
              'ensure'            => 'present',
              'oracle_base_dir'   => '/u01/app/oracle',
              'ora_inventory_dir' => '/u01/app/oraInventory',
              'os_user'           => 'oracle',
              'os_group'          => 'oinstall',
              'download_dir'      => '/install',
           })
        end
      end

      describe "oradb orainst" do
        it do
          should contain_oradb__utils__dborainst('database orainst 12.1.0.1_12.1.0.1_Linux-x86-64').with({
             'ora_inventory_dir' => '/u01/app/oraInventory',
             'os_group'          => 'oinstall',
           })
        end
      end
    end
    context 'with oradb_inst_loc_data=/u01/app/oraInventory' do

      facts = default_facts.merge( { :oradb_inst_loc_data => '/u01/app/oraInventory' } )
      let(:facts) { facts }
      it { is_expected.to contain_db_directory_structure("oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64").with_ora_inventory_dir('/u01/app/oraInventory') }
      it { is_expected.to contain_oradb__utils__dborainst('database orainst 12.1.0.1_12.1.0.1_Linux-x86-64').with_ora_inventory_dir('/u01/app/oraInventory') }
    end
    context 'with ora_inventory_dir parameter provided' do
      params = default_params.merge( { :ora_inventory_dir => '/ora/inventory/dir' } )
      let(:params) { params }
      context 'and no oradb_inst_loc_data fact' do
        it { is_expected.to contain_db_directory_structure("oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64").with_ora_inventory_dir('/ora/inventory/dir/oraInventory') }
        it { is_expected.to contain_oradb__utils__dborainst('database orainst 12.1.0.1_12.1.0.1_Linux-x86-64').with_ora_inventory_dir('/ora/inventory/dir/oraInventory') }
      end
      context 'and oradb_inst_loc_data fact' do
        #Even with the fact present, the provided ora_inventory_dir is used instead
        facts = default_facts.merge( { :oradb_inst_loc_data => '/u01/app/oraInventory' } )
        let(:facts) { facts }
        it { is_expected.to contain_db_directory_structure("oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64").with_ora_inventory_dir('/ora/inventory/dir/oraInventory') }
        it { is_expected.to contain_oradb__utils__dborainst('database orainst 12.1.0.1_12.1.0.1_Linux-x86-64').with_ora_inventory_dir('/ora/inventory/dir/oraInventory') }
      end
    end
    context 'with invalid ora_inventory_dir parameter' do
      params = default_params.merge( { :ora_inventory_dir => 'not_an_absolute_path' } )
      let(:params) { params }
      it 'should raise an error' do
        expect { expect(subject).to contain_db_directory_structure("oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64") }.to raise_error Puppet::Error,
          /"not_an_absolute_path" is not an absolute path/
      end
    end
    context 'with oracle base = /oracle' do
      params = default_params.merge( { :oracle_base => '/oracle' } )
      let(:params) { params }
      it { is_expected.to contain_db_directory_structure("oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64").with_ora_inventory_dir('/u01/app/oraInventory') }
    end

    describe "oradb response file" do
      it do
        should contain_file("/install/db_install_12.1.0.1_12.1.0.1_Linux-x86-64.rsp").that_requires('Oradb::Utils::Dborainst[database orainst 12.1.0.1_12.1.0.1_Linux-x86-64]')
      end
    end

    describe "oradb file1" do
      it {
           should contain_file("/install/linuxamd64_12c_database_1of2.zip").with({
             'source'  => '/software/linuxamd64_12c_database_1of2.zip',
           }).that_comes_before('Exec[extract /install/linuxamd64_12c_database_1of2.zip]').that_requires('Db_directory_structure[oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64]')
         }
    end

    describe "oradb extract file1" do
      it {
           should contain_exec("extract /install/linuxamd64_12c_database_1of2.zip").with({
             'command'  => 'unzip -o /install/linuxamd64_12c_database_1of2.zip -d /install/linuxamd64_12c_database',
           }).that_requires('Db_directory_structure[oracle structure 12.1.0.1_12.1.0.1_Linux-x86-64]')
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
             'command'  => "/bin/sh -c 'unset DISPLAY;/install/linuxamd64_12c_database/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /install/db_install_12.1.0.1_12.1.0.1_Linux-x86-64.rsp'",
             'creates'  => "/u01/app/oracle/product/12.1/db/dbs",
             'group'    => 'oinstall',
           }).that_requires('Oradb::Utils::Dborainst[database orainst 12.1.0.1_12.1.0.1_Linux-x86-64]').that_requires('File[/install/db_install_12.1.0.1_12.1.0.1_Linux-x86-64.rsp]')
         }
    end

    describe "oracle home" do
      it do
        should contain_file("/u01/app/oracle/product/12.1/db").with({
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
           })
      end
    end

    describe "exec root.sh" do
      it do
        should contain_exec("run root.sh script 12.1.0.1_Linux-x86-64").with({
             'command' => '/u01/app/oracle/product/12.1/db/root.sh',
             'group'   => 'root',
           }).that_requires('Exec[install oracle database 12.1.0.1_Linux-x86-64]')
      end
    end

  end

  describe "CentOS local" do
    let(:params){{
          :version                   => '11.2.0.4',
          :file                      => 'p13390677_112040_Linux-x86-64',
          :database_type             => 'SE',
          :oracle_base               => '/u01/app/oracle',
          :oracle_home               => '/u01/app/oracle/product/11.2/db',
          :ora_inventory_dir         => '/u01/app',
          :user                      => 'oracle',
          :group                     => 'dba',
          :group_install             => 'oinstall',
          :group_oper                => 'oper',
          :remote_file               => false,
          :zip_extract               => true,
          :download_dir              => '/install',
          :puppet_download_mnt_point => '/software',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    describe "oradb utils structure" do
      it do
        should contain_db_directory_structure("oracle structure 11.2.0.4_11.2.0.4_Linux-x86-64").with({
              'ensure'            => 'present',
              'oracle_base_dir'   => '/u01/app/oracle',
              'ora_inventory_dir' => '/u01/app/oraInventory',
              'os_user'           => 'oracle',
              'os_group'          => 'oinstall',
              'download_dir'      => '/install',
           })
      end
    end

    describe "oradb orainst" do
      it do
        should contain_oradb__utils__dborainst('database orainst 11.2.0.4_11.2.0.4_Linux-x86-64').with({
             'ora_inventory_dir' => '/u01/app/oraInventory',
             'os_group'          => 'oinstall',
           })
      end
    end

    describe "oradb response file" do
      it do
        should contain_file("/install/db_install_11.2.0.4_11.2.0.4_Linux-x86-64.rsp").that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.4_11.2.0.4_Linux-x86-64]')
      end
    end

    describe "oradb extract file1" do
      it {
           should contain_exec("extract /install/p13390677_112040_Linux-x86-64_1of7.zip").with({
             'command'  => 'unzip -o /software/p13390677_112040_Linux-x86-64_1of7.zip -d /install/p13390677_112040_Linux-x86-64',
           }).that_requires('Db_directory_structure[oracle structure 11.2.0.4_11.2.0.4_Linux-x86-64]')
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
             'command'  => "/bin/sh -c 'unset DISPLAY;/install/p13390677_112040_Linux-x86-64/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /install/db_install_11.2.0.4_11.2.0.4_Linux-x86-64.rsp'",
             'creates'  => "/u01/app/oracle/product/11.2/db/dbs",
             'group'    => 'oinstall',
           }).that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.4_11.2.0.4_Linux-x86-64]').that_requires('File[/install/db_install_11.2.0.4_11.2.0.4_Linux-x86-64.rsp]')
         }
    end

    describe "oracle home" do
      it do
        should contain_file("/u01/app/oracle/product/11.2/db").with({
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
           })
      end
    end

    describe "exec root.sh" do
      it do
        should contain_exec("run root.sh script 11.2.0.4_Linux-x86-64").with({
             'command' => '/u01/app/oracle/product/11.2/db/root.sh',
             'group'   => 'root',
           }).that_requires('Exec[install oracle database 11.2.0.4_Linux-x86-64]')
      end
    end

  end

  describe "CentOS unpacked" do
    let(:params){{
          :version                   => '11.2.0.3',
          :file                      => 'p10404530_112030_Linux-x86-64',
          :database_type             => 'EE',
          :oracle_base               => '/u01/app/oracle',
          :oracle_home               => '/u01/app/oracle/product/11.2/db',
          :ora_inventory_dir         => '/u01/app',
          :user                      => 'oracle',
          :group                     => 'dba',
          :group_install             => 'oinstall',
          :group_oper                => 'oper',
          :remote_file               => false,
          :zip_extract               => false,
          :download_dir              => '/mnt',
          :puppet_download_mnt_point => '/software',
                }}
    let(:title) {'11.2.0.3_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'OracleLinux' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}


    describe "oradb utils structure" do
      it do
        should contain_db_directory_structure("oracle structure 11.2.0.3_11.2.0.3_Linux-x86-64").with({
              'ensure'            => 'present',
              'oracle_base_dir'   => '/u01/app/oracle',
              'ora_inventory_dir' => '/u01/app/oraInventory',
              'os_user'           => 'oracle',
              'os_group'          => 'oinstall',
              'download_dir'      => '/mnt',
           })
      end
    end

    describe "oradb orainst" do
      it do
        should contain_oradb__utils__dborainst('database orainst 11.2.0.3_11.2.0.3_Linux-x86-64').with({
             'ora_inventory_dir' => '/u01/app/oraInventory',
             'os_group'          => 'oinstall',
           })
      end
    end

    describe "oradb response file" do
      it do
        should contain_file("/mnt/db_install_11.2.0.3_11.2.0.3_Linux-x86-64.rsp").that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.3_11.2.0.3_Linux-x86-64]')
      end
    end

    describe "oradb install database" do
      it {
           should contain_exec("install oracle database 11.2.0.3_Linux-x86-64").with({
             'command'  => "/bin/sh -c 'unset DISPLAY;/mnt/p10404530_112030_Linux-x86-64/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /mnt/db_install_11.2.0.3_11.2.0.3_Linux-x86-64.rsp'",
             'creates'  => "/u01/app/oracle/product/11.2/db/dbs",
             'group'    => 'oinstall',
           }).that_requires('Oradb::Utils::Dborainst[database orainst 11.2.0.3_11.2.0.3_Linux-x86-64]').that_requires('File[/mnt/db_install_11.2.0.3_11.2.0.3_Linux-x86-64.rsp]')
         }
    end

    describe "oracle home" do
      it do
        should contain_file("/u01/app/oracle/product/11.2/db").with({
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
           })
      end
    end

    describe "exec root.sh" do
      it do
        should contain_exec("run root.sh script 11.2.0.3_Linux-x86-64").with({
             'command' => '/u01/app/oracle/product/11.2/db/root.sh',
             'group'   => 'root',
           }).that_requires('Exec[install oracle database 11.2.0.3_Linux-x86-64]')
      end
    end

  end

end

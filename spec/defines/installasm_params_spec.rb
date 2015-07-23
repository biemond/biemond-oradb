require 'spec_helper'

describe 'oradb::installasm', :type => :define do

  describe "wrong grid version" do
    let(:params){{
          :version                 => '11.2.0.1',
          :file                    => 'p13390677_112040_Linux-x86-64_3of7.zip',
          :grid_type                => 'HA_CONFIG',
          :grid_base                => '/app/grid',
          :grid_home                => '/app/grid/product/11.2/grid',
          :remote_file              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
          :user_base_dir             => '/home',
          :user                    => 'grid',
          :group                   => 'asmdba',
          :group_install           => 'oinstall',
          :group_oper              => 'asmoper',
          :group_asm               => 'asmadmin',
          :sys_asm_password        => 'Welcome01',
          :asm_monitor_password    => 'Welcome01',
                }}
    let(:title) {'11.2.0.1_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installasm /app/grid/product/11.2/grid does not exists")
             }.to raise_error(Puppet::Error, /Unrecognized database grid install version, use 11.2.0.4, 12.1.0.1 or 12.1.0.2/)
    end

  end

  describe "wrong O.S." do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'p13390677_112040_Linux-x86-64_3of7.zip',
          :grid_type                => 'HA_CONFIG',
          :grid_base                => '/app/grid',
          :grid_home                => '/app/grid/product/11.2/grid',
          :remote_file              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
          :user_base_dir             => '/home',
          :user                    => 'grid',
          :group                   => 'asmdba',
          :group_install           => 'oinstall',
          :group_oper              => 'asmoper',
          :group_asm               => 'asmadmin',
          :sys_asm_password        => 'Welcome01',
          :asm_monitor_password    => 'Welcome01',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'Windows' ,
                   :kernel          => 'Windows',
                   :osfamily        => 'Windows' }}

    it do
      expect { should contain_notify("oradb::installasm /app/grid/product/11.2/grid does not exists")
             }.to raise_error(Puppet::Error, /Unrecognized operating system, please use it on a Linux or SunOS host/)
    end

  end

  describe "wrong grid type" do
    let(:params){{
          :version                 => '11.2.0.4',
          :file                    => 'p13390677_112040_Linux-x86-64_3of7.zip',
          :grid_type                => 'XXXX',
          :grid_base                => '/app/grid',
          :grid_home                => '/app/grid/product/11.2/grid',
          :remote_file              => false,
          :download_dir             => '/install',
          :puppet_download_mnt_point  => '/software',
          :user_base_dir             => '/home',
          :user                    => 'grid',
          :group                   => 'asmdba',
          :group_install           => 'oinstall',
          :group_oper              => 'asmoper',
          :group_asm               => 'asmadmin',
          :sys_asm_password        => 'Welcome01',
          :asm_monitor_password    => 'Welcome01',
                }}
    let(:title) {'11.2.0.4_Linux-x86-64'}
    let(:facts) {{ :operatingsystem => 'CentOS' ,
                   :kernel          => 'Linux',
                   :osfamily        => 'RedHat' }}

    it do
      expect { should contain_notify("oradb::installasm /app/grid/product/11.2/grid does not exists")
             }.to raise_error(Puppet::Error, /Unrecognized database grid type, please use CRS_CONFIG|HA_CONFIG|UPGRADE/)
    end

  end

end
